# Zane's Dotfile

This is all fully ripped off from [this awesome article](https://www.atlassian.com/git/tutorials/dotfiles)

## Setup process on new machine

### Set up Docker and Earthly

#### Install Docker

```sh
sudo apt-get install -y docker
```

#### [Install Earthly](https://earthly.dev/get-earthly)

```sh
sudo /bin/sh -c '
    wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 \
    -O /usr/local/bin/earthly \
    && chmod +x /usr/local/bin/earthly && /usr/local/bin/earthly bootstrap --with-autocomplete
    '
```

#### [Install homebrew](https://brew.sh/)

```sh
sudo apt install curl gcc
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### `gh` install

```sh
brew install gh
```

#### Install yadm

```sh
sudo apt-get install -y yadm
yadm clone https://github.com/zdog234/dotfiles
```

Create config alias

```sh
alias config='/usr/bin/env git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

Clone

```sh
sudo apt-get install -y git
git clone --bare https://github.com/zdog234/dotfiles $HOME/.cfg
config checkout main
```

## Move stuff to backup

You may need to

```bash
mkdir ~/.backup
```

and then move conflicting files to `.backup`

## Ignore untracked files

```sh
config config --local status.showUntrackedFiles no
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

## Linuxbrew

Install homebrew for linux

## Terminal Setup

1. Install alacritty
2. Install [tdrop](https://github.com/noctuid/tdrop)
3. `sudo apt install sxhkd wmctrl`
4.
