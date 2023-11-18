import os
import platform
import shutil
import site
from pathlib import Path

from pyinfra.operations import apt
import pyinfra
from pyinfra import operations, facts, host
import shlex

# ~/.local/lib/pythonX.Y/site-packages might not exist when script starts
# So we need to manually add it to sys.path
site.addsitedir(site.getusersitepackages())

GLOBAL_CRATES = ["lolcate-rs"]


CARGO_PACKAGES = [
    "skim",
]

NIX_ENV_PACKAGES = ["myPackages"]
INSTALL_TEXLIVE = os.getenv("INSTALL_TEXLIVE", "true").lower() == "true"

HEADLESS = os.getenv("HEADLESS", "false").lower() == "true"
INSTALL_KMONAD = (not HEADLESS) and os.getenv(
    "INSTALL_KMONAD", "true"
).lower() == "true"

LOCAL_BIN = Path.home() / ".local" / "bin"
HEADLESS = os.getenv("HEADLESS", "false").lower() == "true"
UBUNTU_PACKAGES = [
    "python3-pip",
    # for pyenv
    "libedit-dev",
    "build-essential",
    "libssl-dev",
    "zlib1g-dev",
    "libbz2-dev",
    "libreadline-dev",
    "libsqlite3-dev",
    "curl",
    "man-db",
    "libncursesw5-dev",
    "xz-utils",
    "tk-dev",
    "libxml2-dev",
    "libxmlsec1-dev",
    "libffi-dev",
    "liblzma-dev",
    "zsh",
]
if not HEADLESS:
    UBUNTU_PACKAGES.extend(
        [
            "fonts-firacode",
            "libgmp-dev",
        ]
    )
APT_OR_BREW = [
    "podman",
    "shfmt",
    "gh",
]
BREW_PACKAGES = [
    "argocd",
    "asdf",
    "aws-shell",
    "bat",
    "black",
    "clipboard",
    "cookiecutter",
    "copier",
    "devcontainer",
    "fd",
    "fnm",
    "fzf",
    "git-delta",
    "git-lfs",
    "glab",
    "go",
    "gum",
    "hatch",
    "helm",
    "httpie",
    "isort",
    "jq",
    "just",
    "kpt",
    "kubernetes-cli",
    "lazygit",
    "neovim",
    "pdm",
    "pipenv",
    "pipx",
    "pre-commit",
    "prettier",
    "python-launcher",
    "ripgrep",
    "starship",
    "stylua",
    "thefuck",
    "tmux",
    "yq",
    "zellij",
    "zoxide",
    "zsh",
]

BREW_TAPS = [dict(src="kptdev/kpt", url="https://github.com/kptdev/kpt")]
IS_LINUX = platform.system() == "Linux"
IS_MACOS = platform.system() == "Darwin"

if not HEADLESS:
    BREW_TAPS.append(dict(src="homebrew/linux-fonts", present=IS_LINUX))
    BREW_TAPS.append(dict(src="homebrew/cask-fonts", present=IS_MACOS))

    BREW_PACKAGES.extend(
        [
            "texlive",
            "font-symbols-only-nerd-font",
            "font-victor-mono",
            "font-victor-mono-nerd-font",
            "font-fira-code",
            # "font-fira-code-nerd-font",
        ]
    )


def main():
    apt_pkgs, brew_pkgs = process_apt_or_brew(
        APT_OR_BREW, UBUNTU_PACKAGES, BREW_PACKAGES
    )
    if shutil.which("apt-get"):
        pyinfra.operations.apt.packages(packages=apt_pkgs, _sudo=True)

    for tap in BREW_TAPS:
        pyinfra.operations.brew.tap(**tap)
    pyinfra.operations.brew.packages(packages=brew_pkgs)
    print("starting the async stuff")
    install_rancher_desktop()
    install_pyenv()


def install_rancher_desktop():
    if HEADLESS:
        return
    if platform.system() != "Linux":
        return
    apt.key(
        name="Add rancher desktop key",
        src="https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/Release.key",
    )
    apt.repo(
        name="Rancher Desktop repo",
        present=True,
        src="deb [signed-by=/usr/share/keyrings/isv-rancher-stable-archive-keyring.gpg]"
        " https://download.opensuse.org/repositories/isv:/Rancher:/stable/deb/ ./",
        filename="isv-rancher-stable",
    )
    apt.update(cache_time=3600)
    apt.packages(packages=["rancher-desktop"])


def install_pyenv():
    pyenv_root = Path.home() / ".pyenv"
    if not pyenv_root.is_dir():
        operations.git.repo(
            "https://github.com/pyenv/pyenv.git",
            str(pyenv_root),
        )

    pyenv = pyenv_root / "bin" / "pyenv"
    versions = ["3.10.11", "3.11.3"]
    globals = set(check_output([str(pyenv), "global"]).strip().split("\n"))
    print(f"{globals=}")
    print(f"{versions=}")
    installed = [
        line.lstrip("*").strip()
        for line in check_output(
            [str(pyenv), "versions"],
        )
        .strip()
        .split("\n")
    ]
    print(f"{installed=}")

    for version in versions:
        if any(v.startswith(version) for v in installed):
            continue
        run_remote([str(pyenv), "install", version])

    run_remote([str(pyenv), "global", *versions])

    for version in versions:
        print(f"{version=}")
        pip = check_output(
            [
                str(pyenv),
                "which",
                "pip",
            ],
            _env={"PYENV_VERSION": version},
        ).strip()
        pyinfra.operations.pip.packages(["pynvim"], pip=pip)


def check_output(cmd: list[str], **kwargs) -> str:
    return host.get_fact(facts.server.Command, shlex.join(cmd), **kwargs)


def run_remote(cmd: list[str]):
    operations.server.shell(shlex.join(cmd))


def process_apt_or_brew(
    apt_or_brew: list[str], apt: list[str], brew: list[str]
) -> tuple[list[str], list[str]]:
    if shutil.which("apt-get"):
        apt = [*apt, *apt_or_brew]
    elif shutil.which("brew"):
        brew = [*brew, *apt_or_brew]
    else:
        raise RuntimeError("No apt or brew found")
    return apt, brew


main()
