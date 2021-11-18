function main
    interactive_setup
end

function interactive_setup
    if status is-interactive
        setup_coreutils_for_mac

        # Set up general aliases
        . ~/.aliasrc

        # set up gcloud path
        . ~/.config/fish/gcloud.fish

        setup_starship

        setup_direnv
    end
end

function setup_direnv
    direnv hook fish | source
end

function setup_starship
    source (/usr/local/bin/starship init fish --print-full-init | psub)
end


function setup_coreutils_for_mac
    if test -d "/usr/local/opt/coreutils/libexec/gnubin";
        set PATH /usr/local/opt/coreutils/libexec/gnubin $PATH
    end
end

main
