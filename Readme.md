# MacOS Setup Using Nix

## Install

__WARNING__: The following script is a guide for installing. _This script is untested_ But hopefully will be fully workable soon.

```bash
#!/bin/bash

set -xe

configParentDir="$HOME/.config"
repoName="darwin-nix"
configDir="$configParentDir/$repoName"

# make config dir
mkdir -p $configParentDir

#clone this repo
git clone "git@github.com:theNerd247/$repoName.git" $configDir

#install nix
sh <(curl -L https://nixos.org/nix/install)

#install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

#run nix-darwin build
darwin-rebuilt switch --flake $configDir
```
