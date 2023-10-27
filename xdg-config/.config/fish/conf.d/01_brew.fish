
test -d $HOME/homebrew; or return 1

set -gx PATH $HOME/homebrew/bin $PATH
set -g fish_function_path (brew --prefix)/share/fish/functions $fish_function_path

if test -d (brew --prefix)"/share/fish/completions"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -gx fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end
