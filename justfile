default:
    ./install

python3:
    brew install python3

link: python3
    #!/usr/bin/env python
    import shutil
    import subprocess as sp

    if not shutil.which("stow"):
        sp.check_call(["brew", "install", "stow"])

    for package in [
        "asdf",
        "autostart",
        "bash",
        "git",
        "go",
        "macos",
        "python",
        "scripts",
        "tabby",
        "vim",
        "vscode",
        "xdg-config",
        "zellij",
        "zsh",
    ]:
        sp.check_call(["stow", "--adopt", package])


    sp.check_call(["git", "stash"])

bootstrap:
    #!/usr/bin/env bash
    command -v python3.11 || brew install python@3.11
    ~/.config/yadm/bootstrap
