# Zane's Dotfiles

I found out about dotfiles from [this awesome article](https://www.atlassian.com/git/tutorials/dotfiles)

## Setup process on new machine

### Pull down dotfiles

```sh
yadm clone https://github.com/zdog234/dotfiles
```

### Install dependencies

#### OSX dependencies

1. [Install homebrew](https://docs.brew.sh/Installation)
2. Install stuff with `brew`

```sh
brew install \
    pyenv \
	gh \
    yadm
```

#### Linx (arch-based)

```sh
sudo pacman -Sy \
	github-cli \
	yadm
```

### Install python + pyinfra

#### OSX

```sh
python3 -m pip install pipx
python3 -m pipx install ensurepath
exec $SHELL
pipx install pyinfra
```

#### Linux (arch-based)

```sh
python -m pip install --user pipx
python3 -m pipx install ensurepath
exec $SHELL
```

#### Linux (debian-based)

```sh
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
echo -n 3.7 3.8 3.9 3.10 3.11 | \
	xargs -d $' ' sh -c \
	'for arg do \
    sudo apt-get install -y \
        python"$arg" \
        python"$arg"-distutils \
        python"$arg"-venv \
	; curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python"$arg" \
	; done'
python3.10 -m pip install pyinfra pipx
```

### `gh` login

```sh
gh auth login
```

### Clone dotfiles

```sh
yadm clone https://github.com/zdog234/dotfiles
```

#### Run pyinfra script

```sh
pyinfra @local ~/.dotfiles/install.py
```

## Ignore untracked files

```sh
yadm gitconfig --local status.showUntrackedFiles no
```

## Install pre-commit hooks

```sh
yadm enter pre-commit install
```

## Install shfmt

Install `shfmt`

```sh
go install mvdan.cc/sh/v3/cmd/shfmt@latest
```

## Terminal Setup

1. Install alacritty
2. Install [tdrop](https://github.com/noctuid/tdrop)
3. `sudo apt install sxhkd wmctrl`
