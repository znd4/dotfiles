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


# eval "$(register-python-argcomplete pipx)"

eval "$(direnv hook zsh)"

eval "$(starship init zsh)"

export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.10/bin:$PATH"



# Created by `pipx` on 2022-01-04 23:54:39
export PATH="$PATH:/Users/zdufour/Library/Python/3.8/bin"

# Created by `pipx` on 2022-01-04 23:54:41
export PATH="$PATH:/Users/zdufour/.local/bin"
