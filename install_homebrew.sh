#!/usr/bin/env sh
set -xe
mkdir -p ~/homebrew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew