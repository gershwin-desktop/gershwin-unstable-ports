# gershwin-unstable-ports
Unstable Gershwin ports fo FreeBSD

## Requirements

* FreeBSD
* git
* poudriere

## Usage

### Generate new ports
This will update all ports in ports-overlay defined in ports list with a new timestamp based on UTC.  It will then generate new distinfo files using latest git commit for each repo.

```
make update
```

### Build the ports
This commmand will create a jail if it does not exist, update the jail if it does.  After this it creates a ports tree if it does not exist, copies in the ports defined in ports.list and builds all of them into packages.

```
make ports
```

### Cleanup
This command cleans up jails, ports, packages.

```
make clean
```


### Installing packages from build artifacts for this respository

```
su

cat > /usr/local/etc/pkg/repos/Gershwin.conf <<\EOF
Gershwin: {
  url: "https://api.cirrus-ci.com/v1/artifact/github/gershwin-desktop/gershwin-unstable-ports/data/packages/FreeBSD:14:amd64",
  mirror_type: "http",
  enabled: yes
}
EOF
```

### Installing gershwin-desktop environmnet
This meta packages installs everything needed for the desktop

```
su
pkg install gershwin-desktop
```

###
This meta package installs requirements to build more GNUstep apps

```
su
pkg install gershwin-developer
```

### Starting the desktop
This requires a working Xorg setup before running

```
. /System/Library/Makefiles/GNUstep.sh
startx GWorkspace
```
