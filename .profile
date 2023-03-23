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

export EDITOR=$(which nvim)
# export PIPENV_VENV_IN_PROJECT=1

unset CURL_CA_BUNDLE

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

. ~/.dotfiles/path_functions.sh

##########################################################################
########## Add to path
##########################################################################

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/bin"

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/.local/bin"

GOROOT="$HOME/go"
GOPATH="$GOROOT/bin"

add_to_path "$GOPATH"
add_to_path "/usr/local/go/bin"

if [ $(uname -s) != 'Darwin' ]; then
	# Start all of my after-login systemd services
	check_path systemctl && systemctl --user start autostart.service
	# make capslock behave like ctrl when held
	check_path setxkbmap && setxkbmap -option 'caps:ctrl_modifier'
	# make capslock behave like esc when tapped
	check_path xcape && xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'

	# OnePassword
	# if which 1password; then
	# 	1password --silent >/dev/null 2>&1 &
	# fi
else
	eval $(/opt/homebrew/bin/brew shellenv)
	add_to_path /opt/local/bin
	add_to_path /opt/local/sbin
fi

# export PYENV_ROOT="$HOME/.pyenv"
# add_to_path "$PYENV_ROOT/bin"
#
# eval `pyenv init --path`

# use 1password for ssh
export SSH_AUTH_SOCK=~/.1password/agent.sock

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

add_to_path "$HOME/.rd/bin"
add_to_path "/usr/local/bin"

[[ -s "/Users/zdufour/.gvm/scripts/gvm" ]] && source "/Users/zdufour/.gvm/scripts/gvm"

. "$HOME/.cargo/env"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
