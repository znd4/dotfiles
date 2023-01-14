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
