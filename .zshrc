#!/usr/bin/env zsh
# Add aliases
. "$HOME/.aliasrc"
. "$HOME/.dotfiles/path_functions.sh"

is_windows || ulimit -n 8096

export SHELL=$(which zsh)

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

# [[ -f ~/Git/zsh-snap/znap.zsh ]] ||
#     git clone --depth 1 -- \
#         https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap
#
# source ~/Git/zsh-snap/znap.zsh  # Start Znap

if [[ ! -f ~/.zpm/zpm.zsh ]]; then
  git clone --recursive https://github.com/zpm-zsh/zpm ~/.zpm
fi
source ~/.zpm/zpm.zsh

zpm load TheLocehiliosan/yadm,path:/completion/zsh/_yadm
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
zpm load jeffreytse/zsh-vi-mode
zpm load mroth/evalcache

_evalcache starship init zsh --print-full-init
# eval "$(starship init zsh --print-full-init)"

zpm load zsh-users/zsh-autosuggestions
zpm load zsh-users/zsh-completions

zpm load Aloxaf/fzf-tab
zpm load ryutok/rust-zsh-completions,fpath:/src

_evalcache zoxide init zsh

_evalcache thefuck --alias


check_path kubectl && _evalcache kubectl completion zsh
check_path op && _evalcache      op completion zsh
check_path fnm && _evalcache    fnm completions --shell zsh
check_path gh && _evalcache gh completion --shell zsh
check_path circleci && _evalcache circleci completion zsh
check_path wezterm && _evalcache wezterm shell-completion --shell zsh
check_path jira && _evalcache jira completion zsh
check_path pack && _evalcache cat ~/.pack/completion.zsh
check_path pdm && _evalcache pdm completion zsh
check_path register-python-argcomplete && check_path pipx && _evalcache register-python-argcomplete pipx
check_path hugo && _evalcache hugo completion zsh
check_path cdktf && . `cdktf completion`


_evalcache direnv hook zsh
_evalcache fnm env --use-on-cd

_evalcache http https://raw.githubusercontent.com/zdog234/nx-completion/main/nx-completion.plugin.zsh

# if which vivaldi &>/dev/null; then
#     export BROWSER=`which vivaldi`
# fi



setopt completealiases # so that gh works when aliased by op plugin

# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
zpm load  zsh-users/zsh-syntax-highlighting


_evalcache zoxide init zsh

autoload -U compinit && compinit

#####################
### volta
#####################

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi


export PYENV_ROOT="$HOME/.pyenv"
check_path pyenv || export PATH="$PYENV_ROOT/bin:$PATH"
check_path pyenv && eval "$(pyenv init -)"

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

add_to_path "$HOME/.cargo/bin"


# Hishtory Config:
add_to_path "$HOME/.hishtory"
source_if_exists "$HOME/.hishtory/config.zsh"

export PATH="$PATH:$HOME/.aido"


# TODO - get this working on new desktop
source_if_exists "$HOME/.config/op/plugins.sh"


# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
