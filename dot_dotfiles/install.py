from functools import wraps
from pyinfra.operations import apt, brew, server, files, git, pip
from pathlib import Path
from pyinfra import host
from pyinfra.facts.server import Home
from pyinfra import facts as facts
from pathlib import PurePosixPath
import shlex

def main():
    configure_repos()
    install_packages()
    brew_installs()
    script_installs()
    install_vundle()


def skipif(condition: bool):
    """
    Skip install function if `condition` is truthy
    """

    def decorator(func):
        @wraps(func)
        def wrapped_func(*args, **kwargs):
            if condition:
                return

            return func(*args, **kwargs)

        return wrapped_func

    return decorator


def get_os_platform() -> str:
    """
    Returns `uname` result, `strip`ped and `lower`ed.

    e.g.
        "darwin"
    """
    return host.get_fact(facts.server.Command, "uname").lower().strip()


def _get_home() -> Path:
    return PurePosixPath(host.get_fact(Home))


@skipif(get_os_platform() == "darwin")
def configure_repos():
    """
    Configure OS repos (apt, pacman, yum etc.)
    """
    apt.ppa(
        src="ppa:appimagelauncher-team/stable",
        name="Add appimagelauncher repo",
        sudo=True,
    )
    apt.key(
        name="Add signal desktop key",
        src="https://updates.signal.org/desktop/apt/keys.asc",
        sudo=True,
    )
    apt.repo(
        "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main",
        present=True,
        filename="signal-xenial",
        sudo=True,
    )


def brew_installs():
    brew.packages(
        name="Install os-agnostic brew packages",
        packages=[
            "diceware",
            "glow",
            "jesseduffield/lazygit/lazygit",
            "thefuck",
            "zoxide",
            ],
    )
    if not host.get_fact(facts.server.Which, "fzf"):
        brew.packages(
            name="Install fzf",
            packages=["fzf"],
        )
        # --all is needed. Otherwise, `install` will have an interactive prompt
        server.shell(commands=["$(brew --prefix)/opt/fzf/install --all"])

    if get_os_platform() == "darwin":
        brew.tap("microsoft/git")

        brew.casks(
            name="Install brew casks",
            casks=["signal", "phoenix", "git-credential-manager-core"],
            upgrade=True,
        )


def script_installs():
    install_macports()
    server.shell(
        name="Install starship",
        commands=[
            'sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes',
        ],
        sudo=True,
    )

    install_joplin()

    install_vim_plug()
    install_delta()
    install_vscode()
    install_nerd_fonts()
    install_rust()

    install_alacritty()
    install_kitty()
    install_tdrop()

    python_setup()

    install_pretty_tmux()


def python_setup():
    versions = install_pyenv()
    install_neovim_python()
    pipx_installs()
    register_jupyter_kernels(versions)


def pipx_installs():
    packages = ["black", "jupyterlab", "virtualenv"]
    server.shell(
        name="Install pipx packages",
        commands=[f"pipx install {package}" for package in packages],
    )


def register_jupyter_kernels(versions: list[str]):
    server.shell(
        name="Install ipython into jupyterlab venv",
        commands=["pipx inject jupyterlab ipython"],
    )
    for version in versions:
        pip.packages(
            name=f"Install ipykernel into {version}",
            packages=["ipykernel", "ipython"],
            pip=f"~/.pyenv/versions/{version}/bin/pip",
        )
    server.shell(
        name=f"ipython kernel installs: {', '.join(versions)}",
        commands=[
            f"PYENV_VERSION={version} pyenv exec ipython kernel install --name={version} --user"
            for version in versions
        ],
    )


#        server.shell(name=f"Registering {version} with ipython kernel install")


@skipif(host.get_fact(facts.files.Link, _get_home() / ".tmux.conf"))
def install_pretty_tmux():
    """
    Follows these instructions:
    https://github.com/gpakosz/.tmux#installation
    $ git clone https://github.com/gpakosz/.tmux.git /path/to/oh-my-tmux
    $ ln -s -f /path/to/oh-my-tmux/.tmux.conf ~/.tmux.conf
    $ cp /path/to/oh-my-tmux/.tmux.conf.local ~/.tmux.conf.local
    """

    tmux_repo_dir = _get_home() / ".local" / "share" / ".tmux"

    server.shell(
        name="clone .tmux.git",
        commands=[
            shlex.join(
                [
                    "git",
                    "clone",
                    "https://github.com/gpakosz/.tmux.git",
                    str(tmux_repo_dir),
                ]
            )
        ],
    )
    files.link(
        _get_home() / ".tmux.conf",
        tmux_repo_dir / ".tmux.conf",
    )


@skipif(get_os_platform() != "darwin")
@skipif(host.get_fact(facts.server.Which, "port"))
def install_macports():
    pkg_path = "/tmp/macports.pkg"
    files.download(
        "https://github.com/macports/macports-base/releases/download/v2.7.1/MacPorts-2.7.1-12-Monterey.pkg",
        pkg_path,
        name="Download macports installer",
    )
    server.shell(
        commands=[f"installer -pkg {pkg_path} -target /"],
        sudo=True,
    )


def install_neovim_python():
    server.shell(
        commands=[
            # exit 0 so that we don't throw an error if there isn't
            # an activated pyenv environment
            "pyenv deactivate 2>/dev/null; exit 0",
            "python3.8 -m pip install neovim",
        ]
    )


def install_pyenv():
    version_output: Optional[str] = host.get_fact(
        facts.server.Command,
        "pyenv versions --bare",
    )

    if version_output:
        existing_versions = set(version_output.strip().split())
    else:
        existing_versions = set()

    _versions = [
        "3.7.12",
        "3.8.12",
        "3.9.9",
        "3.10.0",
    ]
    for _version in _versions:
        if _version in existing_versions:
            continue
        server.shell(
            name=f"Install python=={_version}",
            commands=[f"pyenv install {_version}"],
        )

    server.shell(
        name="pyenv global",
        commands=[f"pyenv global {' '.join(_versions)}"],
    )
    install_black(versions=_versions)
    return _versions


def install_black(*, versions):
    server.shell(
        name="install black",
        commands=[
            f"PYENV_VERSION={version} python -m pip install black"
            for version in versions
        ],
    )


@skipif(get_os_platform() == "darwin")
def install_joplin():
    if host.get_fact(facts.files.File, _get_home() / ".joplin" / "VERSION"):
        return
    server.shell(
        name="install joplin",
        commands=[
            "wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh "
            "| TERM=linux bash --login -s -- --silent"
        ],
    )


@skipif(get_os_platform() == "darwin")
@skipif(host.get_fact(facts.server.Which, "tdrop"))
def install_tdrop():
    tmpdir = "/tmp/tdrop"
    git.repo("https://github.com/noctuid/tdrop", tmpdir)
    server.shell(
        name="installing tdrop",
        commands=["make install"],
        sudo=True,
        chdir=tmpdir,
    )


def install_rust():
    server.shell(
        name="Install rust",
        commands=["curl https://sh.rustup.rs -sSf | sh -s -- -y"],
    )


def install_vscode():
    if host.get_fact(facts.server.Which, "code"):
        print("vscode already installed")
        return

    if get_os_platform() == "darwin":
        brew.casks(name="install vscode with brew", casks=["visual-studio-code"])
        return

    download_path = "/tmp/vscode.deb"
    files.download(
        "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64",
        download_path,
        name="Downloading vscode.deb",
    )
    server.shell(
        name="Installing vscode",
        commands=[f"dpkg -i {download_path}"],
        sudo=True,
    )


def install_vim_plug():
    if not host.get_fact(
        facts.files.File, _get_home() / ".vim" / "autoload" / "plug.vim"
    ):
        print("installing vim-plug")
        server.shell(
            name="Install [vim plug](https://github.com/junegunn/vim-plug)",
            commands=[
                "curl -fLo ~/.vim/autoload/plug.vim --create-dirs "
                "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
            ],
        )
    nvim_path = (
        _get_home() / ".local" / "share" / "nvim" / "site" / "autoload" / "plug.vim"
    )
    if not host.get_fact(
        facts.files.File,
        str(nvim_path),
    ):
        print("installing vim-plug for neovim")
        files.directory(nvim_path.parent)
        files.download(
            "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
            str(nvim_path),
        )

    print("installing plugins with vim-plug")
    server.shell(
        name="Install vim plugins with vim plug",
        commands=[
            # "vim -E -s +PlugInstall +visual +qall",
            # "vim -E -s +PlugUpdate +visual +qall",
            "nvim +'PlugInstall --sync' +qa",
            # "nvim +'PlugUpdate --sync' +qa",
        ],
        _shell_executable="bash",
    )


def install_delta():
    if host.get_fact(facts.server.Which, "delta"):
        return

    if get_os_platform() == "darwin":
        brew.packages(name="brew install git-delta", packages=["git-delta"])
        return

    download_path = "/tmp/git-delta.deb"
    files.download(
        "https://github.com/dandavison/delta/releases/download/0.10.3/git-delta_0.10.3_amd64.deb",
        download_path,
    )
    server.shell(
        name="install [git-delta](https://github.com/dandavison/delta)",
        commands=[f"dpkg -i {download_path}"],
        sudo=True,
    )


def install_packages():
    """
    Install packages with system's package manager
    (e.g. apt, pacman)
    """
    common_packages = [
        "bat",
        "ddgr",
        "direnv",
        "neovim",
        "podman",
        "tmux",
        "unzip",
        "xclip",
        "xdotool",
        "zoxide",
    ]
    if get_os_platform() == "linux":
        install_apt_packages(common_packages)
    elif get_os_platform() == "darwin":
        install_macos_brew_packages(common_packages)
    else:
        raise NotImplementedError(get_os_platform())


def install_macos_brew_packages(common_packages):
    packages = common_packages + [
        "antigen",
        "cmake",
        "dbmate",
        "go",
        "golang",
        "hammerspoon",
        "nativefier",
        "nodejs",
        "pipx",
        "python",
        "ripgrep",  # rg
        "the_silver_searcher",  # ag
        "zplug",
    ]
    packages = packages + python_build_dependencies()
    print(f"{packages=}")
    brew.packages(
        name="install common packages with brew for macos",
        packages=packages,
        latest=True,
        update=True,
    )


def install_apt_packages(common_packages):
    apt.update(sudo=True)

    packages = common_packages + [
        "appimagelauncher",
        "golang-go",
        "python3-pip",
        "signal-desktop",
        "sxhkd",
        "virtualbox",
    ]
    packages = packages + python_build_dependencies()
    server.packages(
        packages=packages,
        sudo=True,
    )


def python_build_dependencies():
    if get_os_platform() == "darwin":
        return [
            "openssl",
            "readline",
            "sqlite3",
            "xz",
            "zlib",
        ]
    elif get_os_platform() == "linux":
        return [
            "libbz2-dev",
            "libc6-dev",
            "libgdbm-dev",
            "libncursesw5-dev",
            "libsqlite3-dev",
            "libssl-dev",
            "tk-dev",
            "build-essential",
            "clang",
            "curl",
            "git",
            "libbz2-dev",
            "libffi-dev",
            "liblzma-dev",
            "libncurses5-dev",
            "libncursesw5-dev",
            "libreadline-dev",
            "libsqlite3-dev",
            "libssl-dev",
            "llvm",
            "make",
            "python3-openssl",
            "tk-dev",
            "wget",
            "xz-utils",
            "zlib1g-dev",
        ]


def install_vundle():
    vundle_dir = str(
        PurePosixPath(host.get_fact(Home)) / ".vim" / "bundle" / "Vundle.vim"
    )
    if not host.get_fact(facts.files.Directory, vundle_dir):
        git.repo(
            "https://github.com/gmarik/Vundle.vim.git",
            vundle_dir,
        )

    server.shell(
        name="Install vundle and install vundle plugins",
        commands=[
            "vim +PluginInstall +qall",
            "vim +PluginUpdate +qall",
            "nvim +PluginInstall +qall",
            "nvim +PluginUpdate +qall",
        ],
    )

    build_you_complete_me()


def build_you_complete_me():
    plugin_dir = _get_home() / ".vim" / "bundle" / "YouCompleteMe"
    print(f"run `cd {plugin_dir} && $(brew --prefix)/bin/python3 install.py --all`")
    # server.shell(
    #     name="Build YouCompleteMe",
    #     chdir=str(plugin_dir),
    #     shell_executable="zsh",
    #     get_pty=True,
    #     commands=[
    #         "git submodule update --init --recursive",
    #         "zsh --login -c '$(brew --prefix)/bin/python3 install.py --all'",
    #     ],
    # )


def install_nerd_fonts():
    if get_os_platform() == "darwin":
        brew.tap("homebrew/cask-fonts")
        brew.casks(casks=["font-fira-code-nerd-font", "font-fira-mono-nerd-font"])
        return

    fc_list_result = host.get_fact(
        facts.server.Command,
        # exit 0 so pyinfra doesn't error out
        "fc-list | grep -i nerd; exit 0",
    )
    if fc_list_result and fc_list_result.strip():
        return
    tmp_firacode = "/tmp/firacode.zip"
    files.download(
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip",
        tmp_firacode,
    )
    fonts_dir = str(_get_home() / ".local" / "share" / "fonts")
    files.directory(fonts_dir, name="Create ~/.local/share/fonts")
    server.shell(
        name="Install fira code", commands=[f"unzip {tmp_firacode} -d {fonts_dir}"]
    )


def install_alacritty():
    if host.get_fact(facts.server.Which, "alacritty"):
        return
    if get_os_platform() == "darwin":
        brew.casks(name="install Alacritty with brew", casks=["alacritty"])
        return

    alacritty_dir = "/tmp/alacritty"
    files.directory(alacritty_dir, present=False)

    server.shell(
        name="cloning alacritty",
        commands=[
            shlex.join(
                [
                    "git",
                    "clone",
                    "https://github.com/alacritty/alacritty.git",
                    alacritty_dir,
                ]
            )
        ],
        _shell_executable="bash",
    )

    server.shell(
        name="Check rust compiler version",
        commands=[
            "rustup override set stable",
            "rustup update stable",
        ],
    )
    if get_os_platform() == "darwin":
        server.shell(
            name="build alacritty and copy to Applications",
            commands=[
                "rustup target add x86_64-apple-darwin aarch64-apple-darwin",
                "make app-universal",
                "cp -r target/release/osx/Alacritty.app /Applications/",
            ],
            chdir=alacritty_dir,
        )

    install_alacritty_dependencies()
    server.shell(
        name="cargo build alacritty",
        commands=[
            f". ~/.cargo/env; cd {alacritty_dir}; cargo build --release",
        ],
        _shell_executable="bash",
    )

    output = host.get_fact(
        facts.server.Command,
        "infocmp alacritty >/dev/null; echo $?",
    )
    if output != "0":
        print(f"infocmp alacritty {output=}")
        server.shell(
            name="running tic -xe alacritty",
            commands=["tic -xe alacritty,alacritty-direct extra/alacritty.info"],
            sudo=True,
        )
    server.shell(
        name="Install Alacritty Desktop Entry",
        sudo=True,
        commands=[
            " && ".join(
                [
                    f"cd {alacritty_dir}",
                    "cp target/release/alacritty /usr/local/bin",
                    "cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg",
                    "desktop-file-install extra/linux/Alacritty.desktop",
                    "update-desktop-database",
                ]
            )
        ],
    )


def install_alacritty_dependencies():
    server.packages(
        name="Install other alacritty dependencies",
        sudo=True,
        packages=[
            "cmake",
            "pkg-config",
            "libfreetype6-dev",
            "libfontconfig1-dev",
            "libfontconfig-dev",
            "libxcb-xfixes0-dev",
            "libxkbcommon-dev",
            "python3",
        ],
    )


def install_kitty():
    if get_os_platform() == "darwin":
        # if "kitty" in host.get_fact(facts.brew.BrewCasks):
        #     return

        brew.casks(["kitty"])
        return

    server.shell(
        name="Install Kitty",
        commands=[
            "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n",
        ],
    )

    # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in
    # your PATH)
    files.link(
        path=str(_get_home() / ".local" / "bin" / "kitty"),
        target=str(_get_home() / ".local" / "kitty.app" / "bin" / "kitty"),
    )
    # ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
    # Place the kitty.desktop file somewhere it can be found by the OS
    kitty_desktop_src = (
        _get_home()
        / ".local"
        / "kitty.app"
        / "share"
        / "applications"
        / "kitty.desktop"
    )
    kitty_desktop_dst = (
        _get_home() / ".local" / "share" / "applications" / "kitty.desktop"
    )
    server.shell(commands=[f"cp {kitty_desktop_src} {kitty_desktop_dst}"])
    # Update the path to the kitty icon in the kitty.desktop file

    kitty_icon = (
        _get_home()
        / ".local"
        / "kitty.app"
        / "share"
        / "icons"
        / "hicolor"
        / "256x256"
        / "apps"
        / "kitty.png"
    )
    sed_string = f"s|Icon=kitty|Icon={kitty_icon}|g"
    server.shell(
        name="Remapping kitty icon with sed",
        commands=[f'sed -i "{sed_string}" {kitty_desktop_dst}'],
    )


# TODO - Clean up readme + use just python to bootstrap
# TODO - .tmux - https://github.com/gpakosz/.tmux
# TODO - Install docker, podman, and earthly
# TODO - Look into another dotfile CLI tool
# TODO - Install libevdev key mapping
# TODO - refactor into package


main()
