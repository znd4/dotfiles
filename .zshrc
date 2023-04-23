#!/usr/bin/env zsh
# Add aliases
. ~/.aliasrc
. ~/.dotfiles/path_functions.sh

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi

export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_personal"


unset CURL_CA_BUNDLE
unset REQUESTS_CA_BUNDLE
unset NODE_EXTRA_CA_CERTS

setopt HIST_IGNORE_SPACE
setopt interactivecomments

get_aws_secret() {
    setopt local_options pipefail
    aws secretsmanager get-secret-value \
        --secret-id "${1?}" \
    | jq -r '.SecretString|fromjson|.'${2?}
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
znap source TheLocehiliosan/yadm completion/zsh/_yadm
compdef _yadm y

# https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands

[[ -f ~/.fzf.zsh ]] || (
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
        ~/.fzf/install
    )

# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
znap source jeffreytse/zsh-vi-mode

# `znap prompt` makes your prompt visible in just 15-40ms!
znap eval starship "starship init zsh"

znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions

znap source Aloxaf/fzf-tab

znap eval z "zoxide init zsh"

znap eval thefuck "thefuck --alias"


check_path kubectl && znap fpath _kubectl 'kubectl completion zsh'
check_path op && znap fpath _op      "op completion zsh"
check_path fnm && znap fpath _fnm    'fnm completions --shell zsh'
check_path rustup && znap fpath _rustup  'rustup  completions zsh'
check_path cargo && znap fpath _cargo   'rustup  completions zsh cargo'
check_path gh && znap fpath _gh 'gh completion --shell zsh'
check_path circleci && znap fpath _circleci 'circleci completion zsh'
check_path wezterm && znap fpath _wezterm 'wezterm shell-completion --shell zsh'
check_path jira && znap fpath _jira 'jira completion zsh'
check_path pack && znap fpath _pack 'cat ~/.pack/completion.zsh'
check_path cdktf && . `cdktf completion`


znap eval direnv "direnv hook zsh"
znap eval fnm "fnm env --use-on-cd"

znap eval nx "http https://raw.githubusercontent.com/zdog234/nx-completion/main/nx-completion.plugin.zsh"


complete -C `which aws_completer` aws

setopt completealiases # so that gh works when aliased by op plugin

# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
znap source zsh-users/zsh-syntax-highlighting



#####################
### volta
#####################

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi




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


# Omni-completion
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^ ' complete-word
bindkey '^Y' autosuggest-accept

zle -N expand-or-complete-prefix
bindkey '^X^E' expand-or-complete-prefix

zvm_bindkey -i '^F' '<esc>-vv'


export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=55,bg=248,underline"


export NPM_PACKAGES="$HOME/.npm-packages"
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

export PATH="$PATH:$HOME/.aido"

source_if_exists "$HOME/.config/op/plugins.sh"


# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
