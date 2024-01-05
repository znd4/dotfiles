(
 (command
   name: (command_name) @_command
   (#match? @_command "jq|yq")
   argument: (string (string_content) @injection.content)
   (#set! injection.language "jq")
 )
 ;; Don't include the quotes in the capture
)
;; Write your query here like `(node) @capture`,
;; put the cursor under the capture to highlight the matches.
; heredoc with docker-compose yaml
(
 (heredoc_redirect
  (pipeline
   (command
    name: (command_name) @_command
    (#match? @_command "docker-compose|dc|kubectl|k")
   )
  )
  (heredoc_body) @injection.content
  (#set! injection.language "yaml")
 )
)
