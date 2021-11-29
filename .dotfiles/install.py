from pyinfra.operations import apt, brew, server

# Install firacode nerd fonts

def main():
    configure_repos()
    install_packages()
    brew_installs()
    script_installs()

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

def install_packages():
    server.packages(
        packages=["appimagelauncher"],
        sudo=True,
    )

# TODO - Install firacode nerd font
# TODO - Install vscode
# TODO - Install direnv
# TODO - Install 

main()


