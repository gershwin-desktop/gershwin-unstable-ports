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
  jailversion="14.2-RELEASE"

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
    if [ -d "/usr/ports" ]; then
      rm -rf /usr/ports
    fi
    git clone --depth 1 -b 2025Q3 https://github.com/FreeBSD/freebsd-ports.git /usr/ports
  fi

  if ! poudriere -e "$POUDRIERE_ETC" ports -l | grep -q gershwin_ports; then
    poudriere -e "$POUDRIERE_ETC" ports -c -p gershwin_ports -m null -M /usr/ports
  fi
}

update_ports() {
    ports_list_file="./ports.list"
    ports_overlay_dir="./ports-overlay"
    timestamp=$(date "+%Y%m%d%H%M")
    failed=0
    
    [ ! -f "$ports_list_file" ] && { echo "ports.list not found"; return 1; }
    
    while read -r port_path || [ -n "$port_path" ]; do
        case "$port_path" in ''|'#'*) continue ;; esac
        
        port_dir="${ports_overlay_dir}/${port_path}"
        [ ! -d "$port_dir" ] && { failed=$((failed + 1)); continue; }
        
        makefile="$port_dir/Makefile"
        [ ! -f "$makefile" ] && { failed=$((failed + 1)); continue; }
        
        actual_portname=$(grep "^PORTNAME=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        gh_account=$(grep "^GH_ACCOUNT=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        gh_project=$(grep "^GH_PROJECT=" "$makefile" | cut -d= -f2- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        [ -z "$actual_portname" ] && { failed=$((failed + 1)); continue; }
        [ -z "$gh_account" ] && { failed=$((failed + 1)); continue; }
        [ -z "$gh_project" ] && gh_project="$actual_portname"
        
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
            failed=$((failed + 1)); continue
        fi
        
        [ -z "$commit_hash" ] && { failed=$((failed + 1)); continue; }
        
        sed -i '' "s/^DISTVERSION=.*/DISTVERSION=	$timestamp/" "$makefile" && \
        sed -i '' "s/^GH_TAGNAME=.*/GH_TAGNAME=	$commit_hash/" "$makefile" && \
        (cd "$port_dir" && make makesum) || { failed=$((failed + 1)); continue; }
        
    done < "$ports_list_file"
    
    [ $failed -gt 0 ] && return 1
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
  poudriere -e "$POUDRIERE_ETC" bulk -b quarterly -j gershwin_base -p gershwin_ports $(cat ports.list)
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
    echo "Nothing to clean"
  fi

  read_ports_list

  rm -f /usr/ports/Mk/Uses/gershwin.mk 2>/dev/null

  for port in $PORTS_LIST; do
    port_path="/usr/ports/$port"
    rm -rf "$port_path" 2>/dev/null
  done
}
