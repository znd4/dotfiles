if status is-interactive
    . ~/.aliasrc
    source (/usr/local/bin/starship init fish --print-full-init | psub)
end
