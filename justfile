link:
    #!/usr/bin/env bash
    command -v stow || brew install stow
    parallel --verbose stow --adopt {} ::: <<EOF
    asdf
    autostart
    bash
    git
    go
    macos
    python
    scripts
    tabby
    vim
    vscode
    xdg-config
    zsh
    EOF

    git stash

bootstrap:
    #!/usr/bin/env bash
    command -v python3.11 || brew install python@3.11
    ~/.config/yadm/bootstrap
