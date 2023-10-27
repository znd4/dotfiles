function main
    setup_brew
    if status is-interactive
        interactive_setup
    end
end

function interactive_setup
    setup_coreutils_for_mac
    setup_macports

    setup_pyenv

    setup_starship

    setup_direnv
    # https://fishshell.com/docs/current/interactive.html#command-line-editor
    fish_vi_key_bindings
    setup_zoxide

    add_to_path $HOME/.local/bin
    add_to_path $HOME/.cargo/bin
    skim_bind_keys

    set -g fish_function_path $HOME/.config/fish/functions $fish_function_path


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
end

function setup_starship
    starship init fish --print-full-init | source
end

function setup_brew
    test -d $HOME/homebrew; or return 1

    set -gx PATH $HOME/homebrew/bin $PATH
    set -g fish_function_path (brew --prefix)/share/fish/functions $fish_function_path

    if test -d (brew --prefix)"/share/fish/completions"
        set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
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
