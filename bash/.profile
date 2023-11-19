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


##########################################################################
########## Helper Functions
##########################################################################


##########################################################################
########## Add to path
##########################################################################
source "$HOME/.path_functions.sh"

add_to_path "$HOME/homebrew/bin"
add_to_path /opt/homebrew/bin
add_to_path /linuxbrew/.linuxbrew/bin


# use 1password for ssh
# export SSH_AUTH_SOCK=~/.1password/agent.sock

# if running bash
if [ -n "$BASH_VERSION" ]; then
    check_path direnv && eval "$(direnv hook bash)" && eval "$(direnv export bash)"
	# include .bashrc if it exists
	if [ -f "$HOME/.bashrc" ]; then
		. "$HOME/.bashrc"
	fi
elif [ -n "$ZSH_VERSION" ]; then
    check_path direnv && eval "$(direnv hook zsh)" && eval "$(direnv export zsh)"
fi


command -v wezterm >/dev/null || alias wezterm='flatpak run org.wezfurlong.wezterm'

x86_64_pkgconfig=/usr/lib/x86_64-linux-gnu/pkgconfig
if [ -d $x86_64_pkgconfig ]; then
	export PKG_CONFIG_PATH="$x86_64_pkgconfig:$PKG_CONFIG_PATH"
fi


if type brew &>/dev/null; then
	FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi


. "$HOME/.cargo/env"
