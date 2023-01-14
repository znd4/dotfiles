#!/usr/bin/env zsh
# Add aliases
. ~/.aliasrc
. ~/.dotfiles/path_functions.sh

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi

check_path thefuck && eval $(thefuck --alias)

# ssl cert fix for node on aspiration laptop
[ -f "$NETSKOPE_CERT" ] && export NODE_EXTRA_CA_CERTS="${NETSKOPE_CERT?}"

setopt HIST_IGNORE_SPACE
setopt interactivecomments

get_aws_secret() {
    setopt local_options pipefail
    aws secretsmanager get-secret-value \
        --secret-id "${1?}" \
    | jq -r '.SecretString|fromjson|.'${2?}
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


znap source ohmyzsh/ohmyzsh plugins/{git,zsh-navigation-tools,zsh-interactive-cd}

# https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands

# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
znap source jeffreytse/zsh-vi-mode

# `znap prompt` makes your prompt visible in just 15-40ms!
# unset PROMPT
echo $PROMPT
# znap eval starship "starship init zsh --print-full-init"
# znap prompt
eval $(starship init zsh)
print $PROMPT

znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions

znap source Aloxaf/fzf-tab

check_path kubectl && znap fpath _kubectl 'kubectl completion zsh'
check_path op && znap fpath _op      "op completion zsh"
check_path rustup && znap fpath _rustup  'rustup  completions zsh'
check_path cargo && znap fpath _cargo   'rustup  completions zsh cargo'
check_path gh && znap fpath _gh 'gh completion --shell zsh'
complete -C `which aws_completer` aws

# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
znap source zsh-users/zsh-syntax-highlighting

#####################
### NVM
#####################

export NVM_DIR="$HOME/.nvm"

[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

[ -f "$NETSKOPE_CERT" ] && alias nvm="CURL_CA_BUNDLE=\"${NETSKOPE_CERT?}\" nvm"

#####################
### zplug
#####################
[[ -f ~/.local/repos/zplug/init.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/zplug/zplug ~/.local/repos/zplug

source ~/.local/repos/zplug/init.zsh  # Start Znap

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
export EDITOR=vi
if type nvim >/dev/null; then
    export EDITOR=`which nvim`
    export MANPAGER="$EDITOR +Man!"
    export PAGER="$MANPAGER"
    export ZVM_VI_EDITOR=$EDITOR
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# eval "$(register-python-argcomplete pipx)"
# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"

# Omni-completion
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^ ' complete-word
bindkey '^Y' autosuggest-accept

zle -N expand-or-complete-prefix
bindkey '^X^E' expand-or-complete-prefix

zvm_bindkey -i '^F' '<esc>-vv'


export GOPRIVATE=github.com/AspirationPartners

# GO Configuration
export GOROOT=~/go

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=55,bg=248,underline"

check_path direnv && eval "$(direnv hook zsh)"

export NPM_PACKAGES="/home/zdufour/.npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules${NODE_PATH:+:$NODE_PATH}"
export PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

source_if_exists() {
    [ -f "$1" ] && source "$1"
}

source_if_exists "$HOME/.fzf.zsh"
source_if_exists "$HOME/.gvm/scripts/gvm"
source_if_exists "$HOME/.cargo/env"



# Hishtory Config:
add_to_path "$HOME/.hishtory"
source_if_exists "$HOME/.hishtory/config.zsh"

export PATH=$PATH:/Users/zdufour/.aido
