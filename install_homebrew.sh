#!/usr/bin/env bash
set -xe
update_or_install_homebrew() {
    set -xe
    export PATH="$HOME/homebrew/bin:$PATH"
    # if homebrew is already installed, update it
    command -v brew && brew update && brew upgrade && return 0
    mkdir -p ~/homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew    
}
ensure_ruby_linux() {
    set -xe
    # if on macos, return
    [ "$(uname)" = "Darwin" ] && return 0

    # if rbenv is 
    export PATH="$HOME/.rbenv/bin:$PATH"
    command -v rbenv || git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    eval "$(rbenv init -)"


    # if ruby-build dir is not present, clone it
    [ -d ~/.rbenv/plugins/ruby-build ] || \
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

    # add ruby-build to path
    export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

    # if ruby 2.6 is not installed, install it
    version="$(\
        rbenv install --list \
        | grep "^2.6" \
        | sort --reverse \
        | head -n 1 \
        | xargs \
    )"
    echo "version: ${version?}"
    rbenv versions | grep "${version?}" || rbenv install "${version?}"
    rbenv global "${version?}"
}
update_or_install_homebrew
ensure_ruby_linux
