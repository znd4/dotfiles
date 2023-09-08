#!/usr/bin/env sh
set -xe
update_or_install_homebrew() {
    export PATH="$HOME/homebrew/bin:$PATH"
    # if homebrew is already installed, update it
    command -v brew && brew update && brew upgrade && return 0
    mkdir -p ~/homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew    
}
ensure_ruby_linux() {
    # if ruby is already installed, return
    command -v ruby && return 0
    # if apt-get is not installed, return
    command -v apt-get || return 0
    # use sudo if not root
    if [ "$(id -u)" -ne 0 ]; then
        sudo apt-get update
        sudo apt-get install -y ruby
    else
        apt-get update
        apt-get install -y ruby
    fi
}
update_or_install_homebrew
brew install ruby-build
