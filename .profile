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

# make capslock behave like ctrl when held
setxkbmap -option 'caps:ctrl_modifier'

# make capslock behave like esc when tapped
xcape -e 'Caps_Lock=Escape' -t 100

# use 1password for ssh
export SSH_AUTH_SOCK=~/.1password/agent.sock

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

add_to_path() {
    directory=$1
	# todo: if not -d $directory; then mkdir --parents $directory
	# fi
	# export PATH=$...
    if [ -d "$directory" ]; then
        export PATH="$directory:$PATH"
    else
        echo "$directory does not exist" >>/dev/stderr
    fi
}

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/bin"

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/.local/bin"

add_to_path "$HOME/go/bin"

if [ -d "$HOME/bin" ]; then
	. "$HOME/.cargo/env"
fi

x86_64_pkgconfig=/usr/lib/x86_64-linux-gnu/pkgconfig
if [ -d $x86_64_pkgconfig ]; then
    export PKG_CONFIG_PATH="$x86_64_pkgconfig:$PKG_CONFIG_PATH"
fi

# OnePassword
if which 1password; then
	1password --silent >/dev/null 2>&1 &
else
	echo "1password is not installed" >>/dev/stderr
fi

# add linuxbrew directory to PATH
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
