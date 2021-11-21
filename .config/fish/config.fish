function main
    if status is-interactive
        interactive_setup
    end
end

function interactive_setup
    setup_coreutils_for_mac
    setup_macports

    # Set up general aliases
    . ~/.aliasrc
    
    fish_add_path ~/.local/bin
    setup_pyenv

    setup_starship

    setup_direnv
end

function setup_pyenv
    if status is-login
        set PYENV_ROOT ~/.pyenv
        fish_add_path $PYENV_ROOT/bin
        eval (pyenv init --path)
    end
end

function setup_direnv
    direnv hook fish | source
end

function setup_starship
    source (/usr/local/bin/starship init fish --print-full-init | psub)
end

function setup_macports
    if test -d /opt/local
        fish_add_path /opt/local/bin /opt/local/sbin
    end
end

function setup_coreutils_for_mac
    if test -d "/usr/local/opt/coreutils/libexec/gnubin";
        fish_add_path /usr/local/opt/coreutils/libexec/gnubin
    end
end

main
