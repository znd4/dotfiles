function main
    set -g SHELL (which fish)
    setup_direnv
    if status is-interactive
        interactive_setup
    end
end


function interactive_setup
    setup_coreutils_for_mac
    setup_macports

    setup_starship

    # https://fishshell.com/docs/current/interactive.html#command-line-editor
    fish_vi_key_bindings
    setup_zoxide

    add_to_path $HOME/.local/bin
    skim_bind_keys

    set -g fish_function_path $HOME/.config/fish/functions $fish_function_path

    thefuck --alias | source

    set -gx EDITOR nvim

    # Needed for bash aliases to show up in vim etc.
    # https://stackoverflow.com/a/19819036/5071232
    set -gx BASH_ENV ~/.aliasrc

    # needed for rust
    set -gx PKG_CONFIG_PATH /usr/lib/x86_64-linux-gnu/pkgconfig
end


function setup_zoxide
    zoxide init fish | source
end

function setup_pyenv
    if status is-login
        set PYENV_ROOT ~/.pyenv
        set -gx PATH $PYENV_ROOT/bin $PATH
        pyenv init --path | source
    end
    status is-interactive; and pyenv init - | source
end

function setup_direnv
    direnv hook fish | source
    direnv export fish | source
end

function setup_starship
    starship init fish --print-full-init | source
end


function setup_macports
    if test -d /opt/local
        fish_add_path /opt/local/bin /opt/local/sbin
    end
end

function skim_bind_keys
    if not command -q sk
        echo "not binding skim keys"
        return 1
    end
    skim_key_bindings
end

function setup_coreutils_for_mac
    if test -d /usr/local/opt/coreutils/libexec/gnubin
        fish_add_path /usr/local/opt/coreutils/libexec/gnubin
    end
end

main
