source_if_exists() {
    [ -f "$1" ] && source "$1"
}

is_windows() {
  if [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    return 0  # 0 indicates true in bash and zsh scripting
  else
    return 1  # non-zero value indicates false
  fi
}

add_to_path() {
    directory=$1
	# todo: if not -d $directory; then mkdir --parents $directory
	# fi
	# export PATH=$...
    [ -d $1 ] && export PATH="$directory:$PATH"
}

check_path() {
    command -v $1 >/dev/null 
    return $?
}
