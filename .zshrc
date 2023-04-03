#!/usr/bin/env zsh
# Add aliases
. ~/.aliasrc
. ~/.dotfiles/path_functions.sh

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi

export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_personal"

check_path thefuck && eval $(thefuck --alias)

# ssl cert fix for node on aspiration laptop
# [ -f "$NETSKOPE_CERT" ] && export NODE_EXTRA_CA_CERTS="${NETSKOPE_CERT?}"
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
eval $(starship init zsh)

znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions

znap source Aloxaf/fzf-tab

check_path kubectl && znap fpath _kubectl 'kubectl completion zsh'
check_path op && znap fpath _op      "op completion zsh"
check_path rustup && znap fpath _rustup  'rustup  completions zsh'
check_path cargo && znap fpath _cargo   'rustup  completions zsh cargo'
check_path gh && znap fpath _gh 'gh completion --shell zsh'
check_path circleci && znap fpath _circleci 'circleci completion zsh'
check_path wezterm && znap fpath _wezterm 'wezterm shell-completion --shell zsh'
check_path jira && znap fpath _jira 'jira completion zsh'
check_path pack && znap fpath _pack 'cat ~/.pack/completion.zsh'
check_path cdktf && . `cdktf completion`

znap eval nx "http https://raw.githubusercontent.com/zdog234/nx-completion/main/nx-completion.plugin.zsh"
complete -C `which aws_completer` aws

setopt completealiases # so that gh works when aliased by op plugin

# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
znap source zsh-users/zsh-syntax-highlighting

#####################
### NVM
#####################

export NVM_DIR="$HOME/.nvm"
[[ -f $NVM_DIR/nvm.sh ]] ||
    git clone -- \
        https://github.com/nvm-sh/nvm.git $NVM_DIR && (cd $NVM_DIR; pwd; git checkout v0.39.3)

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#####################
### volta
#####################

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


# NETSKOPE_CERT doesn't seem to be needed for nvm anymore

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
else
  echo "brew not found"
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

source_if_exists /Users/zdufour/.config/op/plugins.sh


# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

[[ -s "/home/zanedufour/.gvm/scripts/gvm" ]] && source "/home/zanedufour/.gvm/scripts/gvm"
