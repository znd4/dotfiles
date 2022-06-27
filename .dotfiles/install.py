from functools import wraps
from pyinfra.operations import apt, brew, server, files, git, pip, systemd, pacman
from pathlib import Path
from pyinfra import host
from pyinfra.facts.server import Home
from pyinfra import facts as facts
from pathlib import PurePosixPath
from typing import Literal
import shlex
from dataclasses import dataclass


def main():
    enable_services()
    npm_global_nosudo()
    configure_repos()
    install_packages()
    pipx_installs()
    go_installs()
    script_installs()


PACMAN: list[str] = [
    "polkit-gnome",
    "libvirt",
    "rust",
    "signal-desktop",
]
YAY: list[str] = [
    "tzupdate",
    "discord_arch_electron",
    "nerd-fonts-fira-code",
]
APT: list[str] = []
BREW: list[str] = []


def get_os_platform() -> str:
    """
    Returns `uname` result, `strip`ped and `lower`ed.

    e.g.
        "darwin"
    """
    return host.get_fact(facts.server.Command, "uname").lower().strip()


@dataclass
class Package:
    name: str
    arch: Literal[YAY, PACMAN] = None
    debian: Literal[APT, BREW] = None


PACKAGES = (
    Package("glow", arch=PACMAN, debian=BREW),
    Package("starship", arch=PACMAN, debian=BREW),
    Package("git-delta", arch=PACMAN, debian=BREW),
    Package("fzf", arch=PACMAN, debian=BREW),
    Package("kitty", arch=PACMAN, debian=BREW),
    Package("bashtop", arch=PACMAN, debian=APT),
    Package("the_silver_searcher", arch=PACMAN, debian=BREW),
)


def get_default_package_manager() -> Literal[PACMAN, YAY, BREW, APT]:
    os_platform = get_os_platform()
    if os_platform == "darwin":
        return BREW

    if os_platform != "linux":
        raise NotImplementedError(os_platform)


def wrap_str_packages(packages: tuple[Package | str]) -> tuple[Package]:
    distribution_alias, package_manager = get_distribution_and_default_package_manager()
    default_map = {distribution_alias: package_manager} if distribution_alias else {}

    return tuple(
        (
            Package(package, **default_map) if isinstance(package, str) else package
            for package in packages
        )
    )


def go_installs():
    packages = [
        "github.com/cheat/cheat/cmd/cheat@latest",
    ]
    server.shell(
        name="Installing packages with go: " + ", ".join(packages),
        commands=[shlex.join(["go", "install", package]) for package in packages],
    )


def get_distribution_and_default_package_manager() -> (str, list[Package | str]):
    os_platform = get_os_platform()

    if os_platform == "darwin":
        return "macos", BREW

    if os_platform != "linux":
        raise NotImplementedError(os_platform)

    distro_name = host.get_fact(facts.server.LinuxName).lower()
    if distro_name in {"ubuntu", "debian"}:
        return "debian", APT
    elif distro_name in {"arch linux"}:
        return "arch", PACMAN
    else:
        raise NotImplementedError(f"Haven't implemented {distro_name=}")


def setup_libvirtd():
    YAY.extend(
        [
            "qemu",
            "virt-manager",
            "ebtables",
        ]
    )
    PACMAN.append("libvirt")

    systemd.service(
        name="Enable libvirtd for virtualization",
        service="libvirtd",
        running=True,
        enabled=True,
        _sudo=True,
    )

    user = host.get_fact(facts.server.User)
    server.user(
        user,
        groups=[
            *_get_existing_groups(user),
        ],
    )


def _get_existing_groups(username: str) -> list[str]:
    return host.get_fact(facts.server.Users)[username]["groups"]


def update_package_lists(packages: tuple[Package | str]):
    """Update the global package lists based on what's set for each package in packages."""
    os_platform = get_os_platform()
    (
        distrib_alias,
        default_package_manager,
    ) = get_distribution_and_default_package_manager()
    packages = wrap_str_packages(packages)
    if os_platform == "darwin":
        BREW.extend(packages)
        return

    if os_platform != "linux":
        raise NotImplementedError(os_platform)

    distro_name = host.get_fact(facts.server.LinuxName).lower()
    if distro_name in {"ubuntu", "debian"}:
        for package in packages:
            package.debian.append(package.name)
    elif distro_name in {"arch linux"}:
        for package in packages:
            package.arch.append(package.name)
    else:
        raise NotImplementedError(f"Haven't implemented {distro_name=}")


def enable_services():
    systemd.service(
        name="Restart and enable gnome polkit",
        service="auth-agent.service",
        reloaded=True,
        running=True,
        enabled=True,
        user_mode=True,
    )


def npm_global_nosudo():
    npm_packages = str(_get_home() / ".npm-packages")
    files.directory(npm_packages)


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


def _get_home() -> Path:
    return PurePosixPath(host.get_fact(Home))


def has_apt() -> bool:
    return host.get_fact(facts.server.Which, "apt")


@skipif(get_os_platform() == "darwin")
def configure_repos():
    """
    Configure OS repos (apt, pacman, yum etc.)
    """
    if not has_apt():
        return
    apt.ppa(
        src="ppa:appimagelauncher-team/stable",
        name="Add appimagelauncher repo",
        _sudo=True,
    )
    apt.key(
        name="Add signal desktop key",
        src="https://updates.signal.org/desktop/apt/keys.asc",
        _sudo=True,
    )
    apt.repo(
        "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main",
        present=True,
        filename="signal-xenial",
        _sudo=True,
    )


PIPX_PACKAGES = (
    "black",
    "diceware",
    "jupyterlab",
    "virtualenv",
)


def pipx_installs():
    server.shell(
        name="install packages with pipx: " + ", ".join(PIPX_PACKAGES),
        commands=[
            shlex.join(
                [
                    "pipx",
                    "install",
                    package,
                ],
            )
            for package in PIPX_PACKAGES
        ],
    )


def yay_install(packages: list[str | Package]):
    if not host.get_fact(facts.server.Which, "yay"):
        raise NotImplementedError("need to write script that installs yay")

    server.shell(
        name="install packages with yay: " + ", ".join(packages),
        commands=[
            "echo y |"
            + shlex.join(
                [
                    "yay",
                    "--noconfirm",
                    # "--removemake",
                    "--norebuild",
                    "--noredownload",
                    "--nocleanmenu",
                    "--nodiffmenu",
                    "--sudo=pkexec",
                    # TODO - get pkexec to not keep asking
                    # TODO - copy the pacman rule file into place
                    "-S",
                    *packages,
                ],
            ),
        ],
    )


def brew_installs():
    brew.packages(
        name="Install os-agnostic brew packages",
        packages=[
            # "diceware", # Now that I'm using onepassword for this, I don't think I
            # really need this
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
    python_setup()

    install_macports()

    install_joplin()

    install_vim_plug()
    install_vundle()

    install_nerd_fonts()
    install_rust()

    install_alacritty()
    install_kitty()
    install_tdrop()

    install_pretty_tmux()


def python_setup():
    versions = [
        "3.11-dev",
        "3.10.4",
        "3.9.13",
        "3.8.13",
        "3.7.12",
    ]
    install_pyenv(versions)
    install_neovim_python(versions)
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
        _sudo=True,
    )


def install_neovim_python(versions: list[str]):
    for version in versions:
        if version.startswith("3.11"):
            continue

        pyenv_pip_install(
            version=version,
            packages=["pynvim"],
        )


def install_pyenv(versions: list[str]):
    version_output: Optional[str] = host.get_fact(
        facts.server.Command,
        "pyenv versions --bare; exit 0",
    )

    if version_output:
        existing_versions = set(version_output.strip().split())
    else:
        existing_versions = set()

    for version in versions:
        if version in existing_versions:
            continue
        server.shell(
            name=f"Install python=={version}",
            commands=[f"pyenv install {version}"],
        )

    server.shell(
        name="pyenv global",
        commands=[f"pyenv global {' '.join(versions)}"],
    )
    install_black(versions=versions)
    return versions


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
    if host.get_fact(
        facts.files.File, _get_home() / ".joplin" / "VERSION"
    ) or host.get_fact(facts.server.Which, "joplin-desktop"):
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
        _sudo=True,
        chdir=tmpdir,
    )


def which(command: str) -> bool:
    """Return True iff command is on PATH"""
    return host.get_fact(facts.server.Which, command)


def install_rust():
    if which("rust"):
        return

    server.shell(
        name="Install rust",
        commands=["curl https://sh.rustup.rs -sSf | sh -s -- -y"],
    )


def install_vim_plug():
    if not host.get_fact(
        facts.files.File, _get_home() / ".vim" / "autoload" / "plug.vim"
    ):
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
        files.directory(nvim_path.parent)
        files.download(
            "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
            str(nvim_path),
        )

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


def install_packages():
    """
    Install packages with system's package manager
    (e.g. apt, pacman)
    """
    update_package_lists(PACKAGES)
    if APT:
        apt.packages(
            name="Installing packages with apt",
            packages=APT,
        )
    if BREW:
        brew.packages(
            name="Installing packages with brew",
            packages=BREW,
        )
    if PACMAN:
        install_pacman_packages()
    if YAY:
        yay_install(YAY)

    return

    common_packages = [
        "bat",
        # "ddgr", # needs to be installed with yay on arch
        "direnv",
        "neovim",
        "podman",
        "tmux",
        "unzip",
        "xclip",
        "xdotool",
        "zoxide",
    ]


#     if get_os_platform() == "linux":
#         distro_name = host.get_fact(facts.server.LinuxName).lower()
#         if distro_name in {"ubuntu", "debian"}:
#             install_apt_packages(common_packages)
#         elif distro_name in {"arch linux"}:
#             install_pacman_packages(common_packages)
#         else:
#             raise NotImplementedError(f"Haven't implemented {distro_name=}")
#     elif get_os_platform() == "darwin":
#         install_macos_brew_packages(common_packages)
#     else:
#         raise NotImplementedError(get_os_platform())


def install_pacman_packages():
    pyenv_arch_build_deps = [
        "base-devel",
        "openssl",
        "zlib",
        "xz",
        "tk",
    ]

    packages = [
        *PACMAN,
        *pyenv_arch_build_deps,
        "pyenv",
    ]

    print("installing packages with pacman:", ", ".join(packages))

    pacman.packages(
        name="Install packages with pacman",
        packages=packages,
        present=True,
        update=True,
        _sudo=True,
    )


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
        _sudo=True,
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
            "vim +'PluginInstall --sync' +qall",
            "vim +PluginInstall  +qall",
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
            _sudo=True,
        )
    server.shell(
        name="Install Alacritty Desktop Entry",
        _sudo=True,
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
        _sudo=True,
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
