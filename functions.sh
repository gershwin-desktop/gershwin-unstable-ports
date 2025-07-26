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

poudriere_bulk() {
  poudriere -e "$POUDRIERE_ETC" bulk -j gershwin_base -p gershwin_ports $(cat ports.list)
}

ports_target() {
  main
  create_directories
  install_poudriere_conf
  poudriere_jail
  poudriere_ports
  poudriere_bulk
}

clean_directories() {
  base="/usr/local/gershwin-build"
  
  if [ -d "$base" ]; then
    chflags -R noschg "$base"
    rm -rf "$base"
    echo "Removed directory tree: $base"
  else
    echo "Nothing to clean"
  fi
}
