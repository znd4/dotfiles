#!/usr/bin/env bash
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

##########################################################################
########### Environment Variables
##########################################################################
# set -x

export HOME=${HOME:-/c/Users/dufourz}

unset CURL_CA_BUNDLE
export POETRY_VIRTUALENVS_IN_PROJECT=true

# fzf
export FZF_COMPLETION_DIR_COMMANDS="cd z pushd rmdir"

# use neovim as default pager
export GIT_PAGER=delta
export PAGER="$EDITOR -R"

# use neovim as manpager
export MANPAGER="$EDITOR +Man!"
export MANWIDTH=999

##########################################################################
########## Helper Functions
##########################################################################

. "$HOME/.dotfiles/path_functions.sh"

##########################################################################
########## Add to path
##########################################################################

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path /mingw64/bin
add_to_path "$HOME/scoop/shims"

GOROOT="$HOME/go"
GOPATH="$GOROOT/bin"

add_to_path "$GOPATH"
add_to_path "/usr/local/go/bin"

if [ "$(uname -s)" != 'Darwin' ]; then
	# Start all of my after-login systemd services
	[ -n "$(systemctl --user 2>/dev/null)" ] && systemctl --user start autostart.service
else
	add_to_path "$HOME/homebrew/bin"
	add_to_path /opt/local/bin
	add_to_path /opt/local/sbin
fi

setup_pyenv() {
	# if on windows, do nothing
	uname -s | grep -q 'MINGW' && return 0
	if [ -d "$HOME/.pyenv" ]; then
		export PYENV_ROOT=$HOME/.pyenv
	elif [ -d /home/linuxbrew/bin/.pyenv ]; then
		export PYENV_ROOT=/home/linuxbrew/bin/.pyenv
	fi

	# setup pyenv

	add_to_path "$PYENV_ROOT/bin"
	add_to_path "$PYENV_ROOT/shims"
	check_path pyenv && eval "$(pyenv init -)"
}
setup_pyenv

# use 1password for ssh
# export SSH_AUTH_SOCK=~/.1password/agent.sock

# if running bash
if [ -n "$BASH_VERSION" ]; then
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
fi

x86_64_pkgconfig=/usr/lib/x86_64-linux-gnu/pkgconfig
if [ -d $x86_64_pkgconfig ]; then
	export PKG_CONFIG_PATH="$x86_64_pkgconfig:$PKG_CONFIG_PATH"
fi

# add linuxbrew directory to PATH
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if type brew &>/dev/null; then
	FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

add_to_path "${KREW_ROOT:-$HOME/.krew}/bin"
add_to_path "/usr/local/bin"
add_to_path "$HOME/.local/share/containers/podman-desktop/extensions-storage/podman-desktop.compose/bin/"

source_if_exists "$HOME/.gvm/scripts/gvm"
. "$HOME/.cargo/env"
