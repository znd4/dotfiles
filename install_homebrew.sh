#!/usr/bin/env bash
set -xe -o pipefail
update_or_install_homebrew() {
    export PATH="$HOME/homebrew/bin:$PATH"
    # if homebrew is already installed, update it
    mkdir -p ~/homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew    
}
# command -v brew && brew update && brew upgrade && return 0
if command -v brew; then
    brew update
    brew upgrade
else
    update_or_install_homebrew
fi
