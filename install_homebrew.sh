#!/usr/bin/env sh
set -xe
update_or_install_homebrew() {
export PATH="$HOME/homebrew/bin:$PATH"
# if homebrew is already installed, update it
command -v brew && brew update && brew upgrade && return 0
mkdir -p ~/homebrew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew    
}
update_or_install_homebrew
brew install ruby-build
