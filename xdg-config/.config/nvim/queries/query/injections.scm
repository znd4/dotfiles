(
 predicate
 name: (identifier)
 (#eq? @name "match")
 parameters: (parameters
  (string) @injection.content
  (#set! injection.language "regex")
  ; trim first and last characters (quote characters)
  (#offset! injection.content 1 0 -1 0)
 )
)
