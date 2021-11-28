from pyinfra.operations import apt, brew, server

# Install firacode nerd fonts

server.shell(
    name="install joplin",
    commands=["wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash"],
)

"""
sudo add-apt-repository ppa:appimagelauncher-team/stable
sudo apt update
sudo apt install appimagelauncher
"""
apt.ppa(
    src="ppa:appimagelauncher-team/stable",
    name="Add appimagelauncher repo",
    sudo=True
)

server.packages(
    packages=["appimagelauncher"],
    sudo=True
)

# TODO - Install firacode
# TODO - Install vscode
# TODO - Install starship
# TODO - Install direnv
# TODO - Install 

# apt.packages(
#     name="Install vscode",
# )
