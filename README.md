# Zane's Dotfile

This is all fully ripped off from [this awesome article](https://www.atlassian.com/git/tutorials/dotfiles)

## Setup process on new machine

Create config alias

```sh
alias config='/usr/bin/env git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Clone

```sh
git clone --bare https://github.com/zdog234/dotfiles $HOME/.cfg
config checkout main
```

## Install pre-commit hooks

run pre-commit install

```sh
GIT_DIR=.cfg GIT_WORK_TREE=$HOME pre-commit install
```

## pyenv install

1. First, [install pyenv](https://github.com/pyenv/pyenv-installer)
2. Install all of the python versions

```sh
versions="3.7 3.8 3.9 3.10"

full_versions=$(\
    echo -n $versions | \
        xargs -d ' ' -i bash -c \
        'pyenv install --list \
            | grep -E "^\s+$1\.[0-9]+\s*$" \
            | tail -n 1 \
        ' - '{}'
)

# install
n_cores=4
echo -n $full_versions | xargs -P $n_cores -n1 pyenv install

# set globals
pyenv global $full_versions
```

## pre-commit install

Install pipx and pre-commit

```sh
python3.9 -m pip install --user pipx
pipx install pre-commit
```

Run pre-commit install

```sh
dotfiles pre-commit install
```

## Install shfmt

Install go

```sh
sudo apt install golang-go
```

Install `shfmt`

```sh
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```
