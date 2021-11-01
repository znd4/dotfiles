# Add aliases
. ~/.aliasrc

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/go/bin" ]; then
    PATH="$HOME/go/bin:$PATH"
fi

imp() {
    # get the impersonable service account
    fmt_str=mlops-c
    project_id=$(gcloud projects list --filter="name ~ $fmt_str" --format="value(PROJECT_ID)")
    SERVICE_ACCOUNT=$(
        gcloud iam service-accounts list \
            --project=$project_id \
            --filter="email ~ -developers@" \
            --format="value(email)"
    )

    if [[ -z "${SERVICE_ACCOUNT// /}" ]]; then
        echo "Couldn't find service account" >&2
        return 1
    fi

    # this is how we turn on service account impersonation globally
    gcloud config set auth/impersonate_service_account $SERVICE_ACCOUNT

    echo "Started impersonating $SERVICE_ACCOUNT"
}
unimp() {
    # Undo impersonation
    gcloud config unset auth/impersonate_service_account

    echo "Stopped impersonating"
}

# Editor config
export EDITOR="micro"

# gcloud setup

. ~/.dotfiles/gcloud.sh

if [ -d "$HOME/.dr-proxy" ]; then
    . ~/.dr-proxy/auto_proxy.sh http://internet.ford.com 83
fi

if [ -z ${HTTP_PROXY+x} ]; then
    unset PIP_INDEX_URL
    export GIT_CONFIG=$HOME/.ford.gitconfig
    unalias git
else
    export GIT_CONFIG=$HOME/.ford.proxy.gitconfig
    export PIP_INDEX_URL=https://www.nexus.ford.com/repository/Ford_ML_public/simple
    export NO_PROXY=$NO_PROXY,192.168.99.0/24,192.168.39.0/24,192.168.49.0/24,10.96.0.0/12
fi

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

. ~/.scripts/rc/.zshrc

if [ $(uname) = "Darwin" ]; then
    export ZPLUG_HOME=$(brew --prefix)/opt/zplug
else
    echo "WARNING: Haven't implemented OS"
fi

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

eval "$(register-python-argcomplete pipx)"
