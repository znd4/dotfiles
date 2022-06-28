"if exists("b:current_syntax")
"	unlet b:current_syntax
"endif
"syntax include @SQL syntax/sql.vim
"
"syntax region goSqlString 
"	\ matchgroup=Snip
"	\ start="\`\C\_s*\v(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|WITH)"
"	\ end="\`"
"	\ contains=@SQL
"	\ containedIn=goRawString
"	\ keepend
"
"let b:current_syntax = 'go.sql'
"let b:current_syntax = 'go'
