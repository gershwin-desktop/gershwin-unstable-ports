# gershwin-unstable-ports
Unstable Gershwin ports fo FreeBSD

## Requirements

* FreeBSD 14.2/14.3
* git
* poudriere
* xorg


### How this works

Ports in ports-overylay are treated as meta ports if they have PORTVERSION specified.  Otherwise ports with DISTVERSION will automatically use the latest git hash from master or main branch.  This means everytime this runs the latest Gershwin components are built into ports.  It runs automatically once per day and on commit.  It also allows for local operation outside of Cirrus.

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


### Installing packages for build artifacts from this respository

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

### Starting the desktop
This requires a working Xorg setup before running

```
. /usr/local/GNUstep/System/Library/Makefiles/Gershwin.sh
startx /usr/local/GNUstep/System/Applications/GWorkspace.app/Gworkspace
```
