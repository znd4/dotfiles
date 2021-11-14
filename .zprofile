# Created by `pipx` on 2021-03-25 17:57:03
export PATH="$PATH:$HOME/.local/bin"

##
# Your previous /Users/zdufour/.zprofile file was backed up as /Users/zdufour/.zprofile.macports-saved_2021-07-19_at_22:12:23
##

# MacPorts Installer addition on 2021-07-19_at_22:12:23: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"


eval "$(pyenv init --path)"

. ~/.profile

