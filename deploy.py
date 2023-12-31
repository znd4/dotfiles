import io
import os
import platform
import shutil
import site
from pathlib import Path

import pyinfra
from pyinfra import operations, facts, host
import shlex

# ~/.local/lib/pythonX.Y/site-packages might not exist when script starts
# So we need to manually add it to sys.path
site.addsitedir(site.getusersitepackages())


CARGO_PACKAGES = [
    "skim",
    "lolcate-rs",
]

NIX_ENV_PACKAGES = ["myPackages"]
INSTALL_TEXLIVE = os.getenv("INSTALL_TEXLIVE", "true").lower() == "true"

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
            "appimagelauncher",
        ]
    )
APT_OR_BREW = [
    "gh",
    "jq",
    "podman",
    "shfmt",
    "zoxide",
]
BREW_PACKAGES = [
    "argocd",
    "asdf",
    "aws-shell",
    "bat",
    "black",
    "broot",
    "cheat",
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
    "glow",
    "go",
    "gum",
    "hatch",
    "helm",
    "httpie",
    "isort",
    "just",
    "kpt",
    "kubernetes-cli",
    "lazygit",
    "neovim",
    "opam",
    "pandoc",
    "parallel",
    "pdm",
    "pipenv",
    "pipx",
    "pre-commit",
    "prettier",
    "python-launcher",
    "ripgrep",
    "rustup-init",
    "starship",
    "stylua",
    "siderolabs/talos/talosctl",
    "task",
    "thefuck",
    "tmux",
    "yq",
    "zellij",
    "zk",
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
            "doctl",
            "font-fira-code",
            "font-symbols-only-nerd-font",
            "font-victor-mono",
            "font-victor-mono-nerd-font",
            "texlive",
        ]
    )

APT_PPAS = []
if not HEADLESS:
    APT_PPAS.extend(["ppa:appimagelauncher-team/stable"])


def main():
    apt_pkgs, brew_pkgs = process_apt_or_brew(
        APT_OR_BREW, UBUNTU_PACKAGES, BREW_PACKAGES
    )
    if shutil.which("apt-get"):
        for ppa in APT_PPAS:
            pyinfra.operations.apt.ppa(ppa, _sudo=True)
        pyinfra.operations.apt.packages(packages=apt_pkgs, _sudo=True)

    for tap in BREW_TAPS:
        pyinfra.operations.brew.tap(**tap)
    pyinfra.operations.brew.packages(packages=brew_pkgs)
    print("starting the async stuff")
    install_pyenv()
    cargo_install(CARGO_PACKAGES)
    populate_local_ssh_config()
    populate_ssh_credentials()


def cargo_install(cargo_packages: list[str]):
    if not host.get_fact(facts.server.Which, "cargo"):
        run_remote(["rustup-init", "-y"])

    _env = {
        "PATH": host.get_fact(facts.server.Path) + ":~/.cargo/bin",
    }
    operations.server.shell("rustup default stable", _env=_env)
    installed = {
        line.strip().split()[0]
        for line in check_output(["cargo", "install", "--list"], _env=_env).splitlines()
    }

    for package in set(cargo_packages) - installed:
        run_remote(["cargo", "install", package], _env=_env)


def home():
    return Path(host.get_fact(facts.server.Home))


def install_pyenv():
    pyenv_root = home() / ".pyenv"
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


SERVER_HOSTNAMES = (
    "rpi4-1",
    "rpi4-2",
    "rpi5-1",
    "desktop",
)


LOCAL_SSH_TEMPLATE = """
{%- for hostname in hostnames %}
Host {{ hostname }}
    HostName {{ hostname }}.local
    IdentityFile ~/.ssh/keys/{{ hostname }}.local
    User znd4
{% endfor %}
"""


def populate_local_ssh_config():
    local_ssh_config = home() / ".ssh" / "config.d" / "local"
    pyinfra.operations.files.template(
        io.StringIO(LOCAL_SSH_TEMPLATE),
        str(local_ssh_config),
        hostnames=SERVER_HOSTNAMES,
    )


def populate_ssh_credentials():
    ssh_keys = home() / ".ssh" / "keys"
    ssh_keys.mkdir(parents=True, exist_ok=True)
    for hostname in SERVER_HOSTNAMES:
        pub_key_file = ssh_keys / f"{hostname}.local"

        pub_key_val = host.get_fact(
            pyinfra.facts.server.Command,
            shlex.join(["op", "read", f"op://private/{hostname}.local/public key"]),
        )
        pyinfra.operations.files.put(
            io.StringIO(pub_key_val),
            str(pub_key_file),
        )
        pyinfra.operations.files.file(
            str(pub_key_file),
            user="znd4",
            # group="znd4",
            mode="0600",
        )


main()
