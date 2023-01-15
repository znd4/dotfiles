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

export LANG=en_US.UTF-8
export EDITOR=nvim
# export PIPENV_VENV_IN_PROJECT=1

unset CURL_CA_BUNDLE
export NETSKOPE_CERT='/Library/Application Support/Netskope/STAgent/data/nscacert.pem'

# fzf
export FZF_COMPLETION_DIR_COMMANDS="cd z pushd rmdir"

# use neovim as default pager
export GIT_PAGER=delta
export PAGER='nvim -R'

# use neovim as manpager
export MANPAGER='nvim +Man!'
export MANWIDTH=999

##########################################################################
########## Helper Functions
##########################################################################

add_to_path() {
    directory=$1
	# todo: if not -d $directory; then mkdir --parents $directory
	# fi
	# export PATH=$...
    export PATH="$directory:$PATH"
}

##########################################################################
########## Add to path
##########################################################################

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/bin"

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/.local/bin"

export GOROOT="$HOME/go"
export GOPATH="$GOROOT/bin"

add_to_path "$GOPATH"
add_to_path "/usr/local/go/bin"



if [ `uname -s` != 'Darwin' ]; then
	# Start all of my after-login systemd services
	systemctl --user start autostart.service
	# make capslock behave like ctrl when held
	setxkbmap -option 'caps:ctrl_modifier'
	# make capslock behave like esc when tapped
	xcape -e 'Caps_Lock=Escape;Control_L=Escape;Control_R=Escape'

	# OnePassword
	# if which 1password; then
	# 	1password --silent >/dev/null 2>&1 &
	# fi
else
	eval `/opt/homebrew/bin/brew shellenv`
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

[[ -s "/Users/zdufour/.gvm/scripts/gvm" ]] && source "/Users/zdufour/.gvm/scripts/gvm"

