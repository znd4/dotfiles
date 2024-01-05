(
 (command
   name: (command_name) @_command
   (#match? @_command "jq|yq")
   argument: (raw_string) @jq
 )
 ;; Don't include the quotes in the capture
 (#offset! @jq 0 1 0 -1)
)
;; Write your query here like `(node) @capture`,
;; put the cursor under the capture to highlight the matches.
; heredoc with docker-compose yaml
(
 (pipeline
   (redirected_statement
     body: (command) @_cat (#eq? @_cat "cat")
     )
   (command
     name: (command_name) @_command (#eq? @_command "docker-compose")
   )
 )
 (heredoc_body
    ) @yaml
 (#offset! @yaml 0 0 -1 0)
)
