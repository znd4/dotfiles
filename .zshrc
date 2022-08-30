# Add aliases
. ~/.aliasrc

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi

lg() {
    # start lazygit and change to new directory if we change repos while in lazygit
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
        cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
        rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
    fi
}


export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"


#####################
### zplug
#####################

source `brew --prefix`/opt/zplug/init.zsh

zplug "jeffreytse/zsh-vi-mode"
zplug "zsh-users/zsh-autosuggestions"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/zsh-navigation-tools", from:oh-my-zsh
zplug "plugins/zoxide", from:oh-my-zsh
zplug "plugins/zsh-interactive-cd", from:oh-my-zsh
zplug "plugins/thefuck", from:oh-my-zsh


# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    defer:3, \
    use:"*linux*amd64*"
zplug "junegunn/fzf", use:"shell/*.zsh", defer:3

# Can manage local plugins
if [ -d "~/.zsh" ]; then
	zplug "~/.zsh", from:local
fi

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

#####################
### END zplug
#####################

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit

# 1password autocompletion
eval "$(op completion zsh)"; compdef _op op


# POETRY VIRTUALENVS IN PROJECT
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Editor config
export EDITOR="nvim"
export ZVM_VI_EDITOR=$EDITOR
export MANPAGER="nvim +Man!"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# eval "$(register-python-argcomplete pipx)"
# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

export GOPRIVATE=github.com/AspirationPartners

# GO Configuration
export GOROOT=~/go

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=55,bg=248,underline"

# Created by `pipx` on 2022-01-04 23:54:41
export PATH="$PATH:/Users/zdufour/.local/bin"
export PATH="$PATH:/Users/zdufour/Library/Python/3.8/bin"
eval "$(direnv hook zsh)"

eval "$(starship init zsh)"
if [ -d /home/linuxbrew ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.10/bin:$PATH"
fi


[[ -s "/Users/zdufour/.gvm/scripts/gvm" ]] && source "/Users/zdufour/.gvm/scripts/gvm"

export NPM_PACKAGES="/home/zdufour/.npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

