from pyinfra.operations import apt, brew, server, files
from pathlib import Path
from pyinfra import host 
from pyinfra.facts.server import Home
from pyinfra import facts as facts
from pathlib import PurePosixPath
import shlex

# Install firacode nerd fonts

def main():
    configure_repos()
    install_packages()
    brew_installs()
    script_installs()
    install_vundle()

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
        sudo=True
    )
    apt.repo(
        "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main",
        present=True,
        filename="signal-xenial",
        sudo=True,
    )

def brew_installs():
    brew.packages(
        name="Install lazygit",
        packages=["jesseduffield/lazygit/lazygit"],
    )

def script_installs():
    server.shell(
        name="Install starship",
        commands=[
            'sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes',
        ],
        sudo=True,
    )
    
    server.shell(
        name="install joplin",
        commands=["wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash"],
    )

    install_vim_plug()
    install_delta()

def install_vim_plug():
    if not host.get_fact(facts.files.File, _get_home() / ".vim" / "autoload" / "plug.vim"):
        print("installing vim-plug")
        server.shell(
            name="Install [vim plug](https://github.com/junegunn/vim-plug)",
            commands=[
                "curl -fLo ~/.vim/autoload/plug.vim --create-dirs "
                "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
            ]
        )
    server.shell(
        name="Install vim plugins with vim plug",
        commands=[
            "vim -E -s +PlugInstall +visual +qall",
            "vim -E -s +PlugUpdate +visual +qall",
        ],
    )

def install_delta():
    if host.get_fact(facts.server.Which, "delta"):
        return

    download_path = "/tmp/git-delta.deb"
    files.download(
        "https://github.com/dandavison/delta/releases/download/0.10.3/git-delta_0.10.3_amd64.deb",
        download_path,
    )
    server.shell(
        name="install [git-delta](https://github.com/dandavison/delta)",
        commands=[f"dpkg -i {download_path}"],
        sudo=True
    )


def _get_home() -> Path:
    return PurePosixPath(host.get_fact(Home))

def install_packages():
    apt.update(sudo=True)
    server.packages(
        packages=[
            "appimagelauncher",
            "direnv",
            "signal-desktop",
            "podman",
            "virtualbox",
            "bat",
        ],
        sudo=True,
    )

def install_vundle():
    vundle_dir = str(PurePosixPath(host.get_fact(Home)) / ".vim" / "bundle" / "Vundle.vim")
    if host.get_fact(facts.files.Directory, vundle_dir):
        return
    server.shell(
        commands=[
            shlex.join(
                [
                    "git",
                    "clone",
                    "https://github.com/gmarik/Vundle.vim.git",
                    vundle_dir,
                ],
            ),
            shlex.join(
                [ 
                    "vim",
                    "+PluginInstall",
                    "+qall",
                ]
            )
        ]
    )

def install_nerd_fonts(): 
    return
    raise NotImplementedError()
    server.shell(
        name="install nerd fonts",
        commands=[
            shlex.join(
                [
                    "git",
                    "clone",
                    "https://github.com/ryanoasis/nerd-fonts",
                    "/tmp/nerd-fonts",
                ]
            ),
            shlex.join(
                [
                    ""
                ]
            ),
        ]
    )

# TODO - Install yadm and make sure that yadm has been pulled / updated
# TODO - Install firacode nerd font
# TODO - Install vscode
# TODO - Install alacritty
# TODO - Install + configure alacritty overlay keyboard shortcut
# TODO - Install libevdev
# TODO - Set up local ssh
# TODO - Install earthly


main()


