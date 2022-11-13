# Add aliases
. ~/.aliasrc

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi


aws_secret_edit() {
    # requires `brew install jq moreutils`
    secret_string=$(
        aws secretsmanager get-secret-value --secret-id "$1" \
            | jq -r ".SecretString|fromjson" \
            | vipe --suffix=json \
            | jq -rc .
    )
    if [ $? -ne 0 ]; then
        return 1
    fi
    aws secretsmanager put-secret-value \
        --secret-id="$1" \
        --secret-string=$secret_string
}

lg() {
    # start lazygit and change to new directory if we change repos while in lazygit
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
        cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
        rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
    fi
}

fdf() {
    find . -type d -print | fzf
}

#####################
### znap
#####################

[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap eval starship "starship init zsh --print-full-init"
znap prompt

znap source ohmyzsh/ohmyzsh plugins/{git,zsh-navigation-tools,zsh-interactive-cd}


znap source jeffreytse/zsh-vi-mode
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions

znap source Aloxaf/fzf-tab

znap fpath _kubectl 'kubectl completion zsh'
znap fpath _op      "op completion zsh"
znap fpath _rustup  'rustup  completions zsh'
znap fpath _cargo   'rustup  completions zsh cargo'

# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
znap source zsh-users/zsh-syntax-highlighting

#####################
### zplug
#####################

source `brew --prefix`/opt/zplug/init.zsh
# Set the priority when loading
# (If the defer tag is given 2 or above, run after compinit command)

zplug "changyuheng/fz", defer:1
zplug "rupa/z", use:z.sh

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

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^ ' complete-word
bindkey '^Y' autosuggest-accept

unset CURL_CA_BUNDLE

export GOPRIVATE=github.com/AspirationPartners

# GO Configuration
export GOROOT=~/go

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=55,bg=248,underline"

# Created by `pipx` on 2022-01-04 23:54:41
export PATH="$PATH:/Users/zdufour/.local/bin"
export PATH="$PATH:/Users/zdufour/Library/Python/3.8/bin"
eval "$(direnv hook zsh)"

if [ -d /home/linuxbrew ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.10/bin:$PATH"
fi


export NPM_PACKAGES="/home/zdufour/.npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

source "$HOME/.cargo/env"

