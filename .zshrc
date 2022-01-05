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

# POETRY VIRTUALENVS IN PROJECT
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Editor config
export EDITOR="vim"

export ZPLUG_LOADFILE=$HOME/.zplug_packages.zsh
source $ZPLUG_HOME/init.zsh
if zplug check || zplug install; then
    zplug load
fi

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/zdufour/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# eval "$(register-python-argcomplete pipx)"

eval "$(direnv hook zsh)"

eval "$(starship init zsh)"

export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.10/bin:$PATH"

#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####

#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####

# Created by `pipx` on 2022-01-04 23:54:39
export PATH="$PATH:/Users/zdufour/Library/Python/3.8/bin"

# Created by `pipx` on 2022-01-04 23:54:41
export PATH="$PATH:/Users/zdufour/.local/bin"
