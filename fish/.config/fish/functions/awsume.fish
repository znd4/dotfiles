#AWSume alias to source the AWSume script
# alias awsume="source (pyenv which awsume.fish)"
function awsume --wraps awsume -d "alias awsume=source (pyenv which awsume.fish)"
    source (pyenv which awsume.fish) $argv
end
