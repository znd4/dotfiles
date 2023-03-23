(fenced_code_block
    (info_string (language) @_language)
    (#any-of? @_language "sh" "shell")
    (code_fence_content) @bash
    (#exclude_children! @bash)
)

(fenced_code_block
    (info_string (language) @_language)
    (#any-of? @_language "yml")
    (code_fence_content) @yaml
    (#exclude_children! @yaml)
)


(fenced_code_block
    (info_string (language) @language)
    ; @_language must not be "sh" or "shell"
    (#match? @language "^(sh|shell)\@!.*")
    
    (code_fence_content) @content
    (#exclude_children! @content)
)
