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
    if not host.get_fact(facts.server.Which, "fzf"):
        brew.packages(
            name="Install fzf",
            packages=["fzf"],
        )
        # --all is needed. Otherwise, `install` will have an interactive prompt
        server.shell(commands=["$(brew --prefix)/opt/fzf/install --all"])

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
    install_vscode()


def install_vscode():
    if host.get_fact(facts.server.Which, "code"):
        print("vscode already installed")
        return

    download_path="/tmp/vscode.deb"
    files.download(
        "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64",
        download_path,
        name="Downloading vscode.deb"
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
            ]
        )
    nvim_path = _get_home() / ".local" / "share" / "nvim" / "site" / "autoload" / "plug.vim"
    if not host.get_fact(
            facts.files.File,
            str(nvim_path),
        ):
        print("installing vim-plug for neovim")
        files.directory(nvim_path.parent)
        files.download(
            "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
            nvim_path,
        )

    print("installing plugins with vim-plug")
    server.shell(
        name="Install vim plugins with vim plug",
        commands=[
            "vim -E -s +PlugInstall +visual +qall",
            "vim -E -s +PlugUpdate +visual +qall",
            "nvim +'PlugInstall --sync' +qa",
            "nvim +'PlugUpdate --sync' +qa",
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
    """
    Install packages with system's package manager
    (e.g. apt, pacman)
    """
    apt.update(sudo=True)
    server.packages(
        packages=[
            "appimagelauncher",
            "direnv",
            "signal-desktop",
            "podman",
            "virtualbox",
            "bat",
            "unzip",
            "python3-pip",
            "golang-go",
            "neovim",
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
            "vim +PluginInstall +qall",
            "vim +PluginUpdate +qall",
            "nvim +PluginInstall +qall",
            "nvim +PluginUpdate +qall",
        ]
    )

def install_nerd_fonts(): 
    if host.get_fact(facts.server.Command, "fc-list | grep -i nerd").strip():
        return
    tmp_firacode = "/tmp/firacode.zip"
    files.download(
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip",
        tmp_firacode
    )
    fonts_dir = str(_get_home() / ".local" / "share" / "fonts") 
    files.directory(fonts_dir, name="Create ~/.local/share/fonts")
    server.shell(
        name="Install fira code",
        commands=[f"unzip {tmp_firacode} -d {fonts_dir}"]
    )

# TODO - Install yadm and make sure that yadm has been pulled / updated
# TODO - Install firacode nerd font
# TODO - Install alacritty
# TODO - Install + configure alacritty overlay keyboard shortcut
# TODO - Install libevdev
# TODO - configure local ssh setup to only listen to localhost
# TODO - Install earthly


main()


