
function add_to_path
    # guard clause for empty arg
    test -z $argv[1]; and echo "add_to_path: empty arg" >&2; and return 1
    # guard clause for non-directory arg
    test -d $argv[1]; or echo "add_to_path: not a directory" >&2; and return 2
    set -gx PATH $argv[1] $PATH
end
