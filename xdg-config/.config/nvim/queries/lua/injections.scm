(function_call
    name: (dot_index_expression
        table: (function_call
                 name: ((identifier) @_require.func (#eq? @_require.func "require"))
            arguments: (arguments
                ; (string) @_require.arg 
                ((string)
                 @_require.arg
                 (#eq? @_require.arg "\"packer\"")
                ) ; this is the fix
            )
        )
        field: (identifier) @_startup (#eq? @_startup "startup")
    )
 arguments: (arguments
   (table_constructor
     (field 
       value: (function_definition
           body: (block
               (function_call 
                   name: ((identifier) @_use.name (#eq? @_use.name "use"))
                   arguments: (arguments
                       (table_constructor
                           (field
                                name: (
                                   (identifier) @_use.arg.name 
                                   (#eq? @_use.arg.name "config")
                                )
                                value: [ 
                                    ; TODO - figure out how to support multiple matches without copy-pasting the entire query over and over again
                                    ; this *kind of works*, but the offset gets overridden somehow
                                    (
                                        ((string) @_val (#match? @_val  "^\".+\"$")) @lua
                                         ; (#match? @lua "^\".+\"$")
                                         (#offset! @lua 0 1 -0 -1)
                                    )
                                    (
                                        ((string) @_val2 (#match? @_val2 "^\\[\\[.+\\]\\]$")) @lua
                                         ; (#match? @lua "^\\[\\[.+\\]\\]$")
                                         (#offset! @lua 0 2 -0 -2)
                                    )
                                ]
                           )
                       )
                   )
               )
            )
        )
       )
     )
   )
)

