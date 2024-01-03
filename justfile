default:
    ./install

submodules:
    git submodule update --init --recursive

python3:
    just guarantee python3

adopt: python3
    #!/usr/bin/env bash
    STOW_ADOPT=1 just link

alias delete := unlink
alias d := unlink

unlink:
    STOW_DELETE=1 just link

link: python3 submodules
    #!/usr/bin/env python
    import shutil
    import subprocess as sp
    import os
    import pathlib

    if not shutil.which("stow"):
        sp.check_call(["brew", "install", "stow"])

    cmd = ["stow", "--no-folding"]
    if os.environ.get("STOW_ADOPT", False):
        cmd.append("--adopt")

    if os.environ.get("STOW_DELETE", False):
        cmd.append("--delete")

    for package in [
        "asdf",
        "autostart",
        "bash",
        "fish",
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
        sp.check_call([*cmd, f"--target={pathlib.Path.home()}", package])

    for package, target in [
        (
            pathlib.Path("vendors") / "fzf" / "bin",
            pathlib.Path.home() / '.local' / 'bin',
        ),
        (
            pathlib.Path("vendors") / "xh" / "completions",
            pathlib.Path.home() / ".config" / "fish" / "completions",
        ),
    ]:
        os.makedirs(target, exist_ok=True)
        command=[
            *cmd,
            f"--target={target}",
            package.name,
            f"--dir={package.parent}",
        ]
        print(f"{command=}")
        sp.check_call(command)

    if os.environ.get("STOW_ADOPT", False):
        sp.check_call(["git", "stash"])

guarantee pkg:
    command -v {{ pkg }} || brew install {{ pkg }}

pre-commit-install:
    just guarantee pre-commit
    pre-commit install

bootstrap:
    just guarantee pipx
    pipx run --python=python3.11 \
        --spec git+https://github.com/znd4/pyinfra@add-url-option-to-brew.tap \
        pyinfra -vvv @local deploy.py
    python3.11 install.py
