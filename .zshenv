#!/usr/bin/env zsh
export LANG=en_US.UTF-8
export EDITOR=nvim
# export PIPENV_VENV_IN_PROJECT=1

unset CURL_CA_BUNDLE

# fzf
export FZF_COMPLETION_DIR_COMMANDS="cd z pushd rmdir"

# use neovim as default pager
export PAGER='nvim -R'

# use neovim as manpager
export MANPAGER='nvim +Man!'
export MANWIDTH=999
add_to_path() {
    directory=$1
	# todo: if not -d $directory; then mkdir --parents $directory
	# fi
	# export PATH=$...
    export PATH="$directory:$PATH"
}

add_to_path "$HOME/bin"

# set PATH so it includes user's private bin if it exists
add_to_path "$HOME/.local/bin"

GOROOT="$HOME/go"
GOPATH="$GOROOT/bin"

add_to_path "$GOPATH"
add_to_path "/usr/local/go/bin"

if [ `uname -s` != 'Darwin' ]; then
else
	eval `/opt/homebrew/bin/brew shellenv`
	add_to_path /opt/local/bin
	add_to_path /opt/local/sbin
fi

. "$HOME/.cargo/env"
