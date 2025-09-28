#!/bin/sh

main() {
  export POUDRIERE_ETC="/usr/local/gershwin-build/etc"
  check_requirements
}

check_requirements() {
  if [ "$(id -u)" != "0" ]; then
    echo "Must be run as root"
    exit 1
  fi
  for cmd in git poudriere; do
    command -v "$cmd" >/dev/null 2>&1 || {
      echo "$cmd is required but not found"
      exit 1
    }
  done
}

create_directories() {
  base="/usr/local/gershwin-build"

  for dir in "$base" "$base/etc" "$base/distfiles" "$base/poudriere" "$base/poudriere/data"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
      echo "Created directory: $dir"
    fi
  done
}

install_poudriere_conf() {
  [ -f "$POUDRIERE_ETC/poudriere.conf" ] || cp ./poudriere.conf "$POUDRIERE_ETC/poudriere.conf"
}

poudriere_jail() {
  jailname="gershwin_base"
  jailversion="14.3-RELEASE"

  if ! poudriere -e "$POUDRIERE_ETC" jail -l | grep -q "^$jailname"; then
    echo "Creating jail '$jailname' with FreeBSD $jailversion..."
    poudriere -e "$POUDRIERE_ETC" jail -c \
      -j "$jailname" \
      -v "$jailversion" \
      -a amd64
  else
    echo "Jail '$jailname' already exists. Updating..."
    poudriere -e "$POUDRIERE_ETC" jail -u \
      -j "$jailname"
  fi
}

poudriere_ports() {
  if [ ! -d "/usr/ports" ] || [ -z "$(ls -A /usr/ports 2>/dev/null)" ]; then
    echo "No ports tree found in /usr/ports. Cloning from GitHub..."
    git clone --depth 1 https://github.com/FreeBSD/freebsd-ports.git /usr/ports
  fi

  if ! poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gershwin_ports; then
    poudriere -e "$POUDRIERE_ETC" ports -c -p gershwin_ports -m null -M /usr/ports
  fi
}

update_ports() {
    export POUDRIERE_ETC="/usr/local/gershwin-build/etc"
    create_directories
    install_poudriere_conf
    poudriere_ports
    install_overlay_ports
    ports_list_file="./ports.list"
    ports_overlay_dir="./ports-overlay"
    version_file="/usr/local/gershwin-build/port_version.txt"
    failed=0
    failed_ports=""
    
    # Ensure the directory exists
    mkdir -p "/usr/local/gershwin-build"
    
    # Generate timestamp once and save it to file (overwrite each run)
    timestamp=$(date "+%Y%m%d%H%M")
    echo "$timestamp" > "$version_file"
    echo "Using consistent version: $timestamp (saved to $version_file)"
    
    [ ! -f "$ports_list_file" ] && { echo "ports.list not found"; return 1; }
    
    while read -r port_path || [ -n "$port_path" ]; do
        case "$port_path" in ''|'#'*) continue ;; esac
        echo "Processing port: $port_path"
        
        # Read the consistent timestamp from file
        if [ -f "$version_file" ]; then
            version=$(cat "$version_file")
        else
            echo "ERROR: Version file not found: $version_file"
            failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue
        fi
        
        port_dir="${ports_overlay_dir}/${port_path}"
        [ ! -d "$port_dir" ] && { echo "ERROR: Port directory not found: $port_dir"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        makefile="$port_dir/Makefile"
        [ ! -f "$makefile" ] && { echo "ERROR: Makefile not found: $makefile"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        
        # Simple detection: PORTVERSION = meta port, DISTVERSION = regular port
        portversion=$(grep "^PORTVERSION=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        distversion=$(grep "^DISTVERSION=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        if [ -n "$portversion" ]; then
            # Meta port - only update PORTVERSION
            echo "  Detected meta port (PORTVERSION) - only updating version"
            echo "  Updating PORTVERSION to: $version"
            sed -i '' "s/^PORTVERSION=.*/PORTVERSION=       $version/" "$makefile" || { echo "ERROR: Failed to update PORTVERSION"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
            echo "  Successfully processed meta port $port_path"
            echo ""
            continue
        elif [ -n "$distversion" ]; then
            # Regular port - update DISTVERSION and run makesum
            echo "  Detected regular port (DISTVERSION) - updating version and distinfo"
        else
            echo "ERROR: No PORTVERSION or DISTVERSION found in $makefile"
            failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue
        fi
        
        # Regular port processing continues below...
        actual_portname=$(grep "^PORTNAME=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        gh_account=$(grep "^GH_ACCOUNT=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        gh_project=$(grep "^GH_PROJECT=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        gh_tagname=$(grep "^GH_TAGNAME=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        echo "  PORTNAME: $actual_portname"
        echo "  GH_ACCOUNT: $gh_account"
        echo "  GH_PROJECT: $gh_project"
        echo "  GH_TAGNAME found: $([ -n "$gh_tagname" ] && echo "yes" || echo "no")"
        echo "  DISTVERSION found: $([ -n "$distversion" ] && echo "yes" || echo "no")"
        
        [ -z "$actual_portname" ] && { echo "ERROR: PORTNAME not found in $makefile"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        [ -z "$gh_account" ] && { echo "ERROR: GH_ACCOUNT not found in $makefile"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        [ -z "$gh_project" ] && gh_project="$actual_portname"
        
        echo "  Using GH_PROJECT: $gh_project"
        echo "  Fetching commit from GitHub API..."
        
        if command -v fetch >/dev/null 2>&1; then
            api_response=$(fetch -qo - "https://api.github.com/repos/${gh_account}/${gh_project}/commits/master" 2>/dev/null)
            [ -z "$api_response" ] || echo "$api_response" | grep -q '"message":"Not Found"' && \
                api_response=$(fetch -qo - "https://api.github.com/repos/${gh_account}/${gh_project}/commits/main")
            commit_hash=$(echo "$api_response" | sed -n 's/^{"sha":"\([^"]*\)".*/\1/p')
        elif command -v curl >/dev/null 2>&1; then
            api_response=$(curl -s "https://api.github.com/repos/${gh_account}/${gh_project}/commits/master")
            [ -z "$api_response" ] || echo "$api_response" | grep -q '"message":"Not Found"' && \
                api_response=$(curl -s "https://api.github.com/repos/${gh_account}/${gh_project}/commits/main")
            commit_hash=$(echo "$api_response" | sed -n 's/^{"sha":"\([^"]*\)".*/\1/p')
        else
            echo "ERROR: Neither fetch nor curl available"
            failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue
        fi
        
        [ -z "$commit_hash" ] && { echo "ERROR: Could not retrieve commit hash from GitHub API"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        echo "  Commit hash: $commit_hash"
        
        echo "  Updating DISTVERSION to: $version"
        sed -i '' "s/^DISTVERSION=.*/DISTVERSION=       $version/" "$makefile" || { echo "ERROR: Failed to update DISTVERSION"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        
        if [ -n "$gh_tagname" ]; then
            echo "  Updating GH_TAGNAME to: $commit_hash"
            sed -i '' "s/^GH_TAGNAME=.*/GH_TAGNAME= $commit_hash/" "$makefile" || { echo "ERROR: Failed to update GH_TAGNAME"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        else
            echo "  Skipping GH_TAGNAME update (not defined in Makefile)"
        fi
        
        distinfo_file="$port_dir/distinfo"
        if [ -f "$distinfo_file" ]; then
            echo "  Running make makesum..."
            (cd "$port_dir" && make makesum) || { echo "ERROR: make makesum failed for $port_path"; failed=$((failed + 1)); failed_ports="$failed_ports $port_path"; continue; }
        else
            echo "  Skipping makesum (no distinfo file)"
        fi
        
        echo "  Successfully processed $port_path"
        echo ""
    done < "$ports_list_file"
    
    if [ $failed -gt 0 ]; then
        echo ""
        echo "=== SUMMARY ==="
        echo "Total failed ports: $failed"
        echo "Failed ports:$failed_ports"
        echo ""
        
        for failed_port in $failed_ports; do
            echo "Checking if $failed_port is a meta port (no distfiles)..."
            failed_makefile="${ports_overlay_dir}/${failed_port}/Makefile"
            if [ -f "$failed_makefile" ]; then
                if grep -q "^USES.*metaport" "$failed_makefile" || grep -q "^NO_BUILD.*yes" "$failed_makefile" || ! grep -q "^DISTVERSION\|^PORTVERSION" "$failed_makefile"; then
                    echo "  -> $failed_port appears to be a meta port - this may be expected"
                else
                    echo "  -> $failed_port appears to be a regular port - investigate further"
                fi
            else
                echo "  -> Cannot check $failed_port (Makefile not found)"
            fi
        done
        
        return 1
    fi
    echo "All ports processed successfully"
    return 0
}

read_ports_list() {
  PORTS_LIST=$(awk -F/ '{print $0}' ports.list)
}

install_overlay_ports() {
  read_ports_list

  # Install custom Mk/Uses file
  install -d /usr/ports/Mk/Uses
  install -m 0644 ports-overlay/Mk/Uses/gershwin.mk /usr/ports/Mk/Uses/gershwin.mk

  # Replace listed ports
  for port in $PORTS_LIST; do
    port_path="/usr/ports/$port"
    overlay_path="ports-overlay/$port"

    [ -d "$port_path" ] && rm -rf "$port_path"
    install -d "$(dirname "$port_path")"
    cp -a "$overlay_path" "$port_path"
  done
}

poudriere_bulk() {
  poudriere -e "$POUDRIERE_ETC" bulk -j gershwin_base -p gershwin_ports $(cat ports.list)
}

make_ports() {
  main
  create_directories
  install_poudriere_conf
  poudriere_jail
  poudriere_ports
  install_overlay_ports
  poudriere_bulk
}

clean_ports() {
  base="/usr/local/gershwin-build"
  
  if [ -d "$base" ]; then
    chflags -R noschg "$base"
    rm -rf "$base"
    echo "Removed directory tree: $base"
  else
    echo "Nothing to clean for base"
  fi
  
  echo "Removing ports"
  rm -rf /usr/ports/ &>/dev/null
}
