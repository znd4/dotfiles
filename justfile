default:
    ./install

python3:
    #!/usr/bin/env bash
    command -v python3 >/dev/null || brew install python3

adopt: python3
    #!/usr/bin/env bash
    STOW_ADOPT=1 just link

link: python3
    #!/usr/bin/env python
    import shutil
    import subprocess as sp
    import os

    if not shutil.which("stow"):
        sp.check_call(["brew", "install", "stow"])

    cmd = ["stow"]
    if os.environ.get("STOW_ADOPT", False):
        cmd.append("--adopt")


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
        sp.check_call([*cmd, package])


    if os.environ.get("STOW_ADOPT", False):
        sp.check_call(["git", "stash"])

guarantee pkg:
    command -v {{pkg}} || brew install {{pkg}}

pre-commit-install:
    just guarantee pre-commit
    pre-commit install

bootstrap:
    just guarantee pipx
    pipx run pyinfra @local deploy.py
