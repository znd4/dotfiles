function main
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
    setup_brew

	# Needed for bash aliases to show up in vim etc.
	# https://stackoverflow.com/a/19819036/5071232
	set -gx BASH_ENV ~/.aliasrc

	# needed for rust
	set -gx PKG_CONFIG_PATH /usr/lib/x86_64-linux-gnu/pkgconfig
end


function setup_pyenv
    if status is-login
        set PYENV_ROOT ~/.pyenv
        fish_add_path $PYENV_ROOT/bin
        pyenv init --path | source
    end
    status is-interactive; and pyenv init - | source
end

function setup_direnv
    direnv hook fish | source
end

function setup_starship
    source (/usr/local/bin/starship init fish --print-full-init | psub)
end

function setup_brew
    if test -d /home/linuxbrew/.linuxbrew/bin
        fish_add_path /home/linuxbrew/.linuxbrew/bin 
    end
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
