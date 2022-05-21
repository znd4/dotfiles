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


# make CapsLock behave like Ctrl:
setxkbmap -option ctrl:nocaps

# make short-pressed Ctrl behave like Escape:
xcape -e 'Control_L=Escape'


# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

add_to_path() {
    directory=$1
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

# add linuxbrew directory to PATH
if [ `uname` = "Linux" ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
