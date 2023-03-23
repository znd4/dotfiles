lua require('init')

" Don't yank when pasting over a selection
" see: https://vi.stackexchange.com/a/39151
xnoremap p P

set clipboard+=unnamedplus

" Enable macos system clipboard pasting in neovide
nmap <D-c> "+y
vmap <D-c> "+y
nmap <D-v> "+p
cnoremap <D-v> <c-r>+
inoremap <D-v> <c-r>+
tnoremap <D-v> <c-\><c-n><c-r>+


" Start interactive EasyAlign in visual mode (e.g. vipga)
" https://github.com/junegunn/vim-easy-align
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" setup mapping to call :LazyGit
nnoremap <silent> <leader>gg :LazyGit<CR>


" Add Copy and cut from select mode
vmap <C-c> "+y
vmap <C-x> "+c



" open current file in github
function! GHOpen()
	let cmd = "gh browse " . expand("%") . ":" . line(".")
	echo system(cmd)
endfunction

command! GHOpen :call GHOpen()


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" markdown
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'sh', 'golang', 'go=golang', 'sql', 'js']


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/ruanyl/vim-gh-line
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gh_use_canonical = 1 " open permalink, not branch

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    FISH
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" From https://github.com/dag/vim-fish
" Set up :make to use fish for syntax checking.
if &shell =~# 'fish$'
    set shell=bash
    setlocal foldmethod=expr
endif
