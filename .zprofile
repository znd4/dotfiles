# eval "$(/opt/homebrew/bin/brew shellenv)"
# export PATH="$PATH:/opt/homebrew/bin"

. ~/.profile

# if which pyenv-virtualenv-init > /dev/null; then
#     eval "$(pyenv virtualenv-init - zsh)"
# fi


# MacPorts Installer addition on 2021-07-19_at_22:12:23: adding an appropriate PATH variable for use with MacPorts.
# Finished adapting your PATH environment variable for use with MacPorts.
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# 
# eval "$(pyenv init --path)"


# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH

# MacPorts Installer addition on 2022-12-31_at_13:38:20: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
