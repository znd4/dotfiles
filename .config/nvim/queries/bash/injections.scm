(
 (command
   name: (command_name) @_command
   (#eq? @_command "jq")
   argument: (raw_string) @jq
 )
 ;; Don't include the quotes in the capture
 (#offset! @jq 0 1 0 -1)
)
