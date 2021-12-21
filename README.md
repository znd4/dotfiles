# Zane's Dotfile

This is all fully ripped off from [this awesome article](https://www.atlassian.com/git/tutorials/dotfiles)

## Setup process on new machine

### Set up Docker and Earthly

#### Install docker and ssh-server

```sh
sudo apt-get update -y
sudo apt-get install -y docker.io docker openssh-server
```

#### Start ssh service

<- TODO - Might not need this ->
<- TODO - might need to add localhost to /etc/hosts.allow ->
```sh
sudo service ssh start
sudo echo "ListenAddress 127.0.0.1" >> /etc/ssh/sshd_config
sudo systemctl restart ssh
```

#### [Install Earthly](https://earthly.dev/get-earthly)

```sh
sudo /bin/sh -c '
    wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 \
    -O /usr/local/bin/earthly \
    && chmod +x /usr/local/bin/earthly && /usr/local/bin/earthly bootstrap --with-autocomplete
    '
```

#### Install Docker



#### [Configure Earthly]()

```sh
# earthly config global.container_frontend podman-shell
# podman pull docker.io/earthly/buildkitd:v0.5.24
# sudo bash -c \
#	'echo "unqualified-search-registries=[\"docker.io\"]" \
#	>> /etc/containers/registries.conf'
```

#### [Run Earthly] ()

```sh
set IP (hostname -I | grep -Po '172(\.\d+){3}')
cd ~/.dotfiles
sudo earthly +install \
	--IP=$IP \
	--USER=(whoami) \
	--KNOWN_HOSTS=(ssh-keyscan -H $IP) \
	--PASSWORD=(read -s -P "ssh Password: ")
```

#### [Install homebrew](https://brew.sh/)

```sh
sudo apt install curl gcc
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### brew installs

```sh
brew install gh python-launcher pyenv
```

#### Install python

build dependencies

```sh
sudo apt-get update; sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

install python versions

```sh
versions="3.7.12 3.8.12 3.9.9 3.10.0"
echo $versions | xargs -n 1 pyenv install
pyenv global $versions
```

#### `gh` login

```sh
gh auth login
```

#### Install yadm

```sh
sudo apt-get install -y yadm
yadm clone https://github.com/zdog234/dotfiles
```

#### Install fish

```sh
sudo apt-get install -y fish
chsh -s $(which fish)
fish --login
```

#### Run pyinfra script

```fish
python3.10 -m pip install pipx
python3.10 -m pipx ensurepath
pipx install pyinfra
pyinfra @local ~/.dotfiles/install.py
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
yadm gitconfig --local status.showUntrackedFiles no
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
