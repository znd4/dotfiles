" neovide
let g:neovide_transparency=0.0
let g:transparency=0.95
let g:neovide_background_color = '#0f1117'.printf('%x', float2nr(255 * g:transparency))

let g:neovide_input_use_logo=v:true

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

lua require('init')
au! BufWritePost */lua/*.lua lua require('packer').compile()

set nocompatible              " required
filetype plugin on                  " required
syntax on

set guifont="FiraCode Nerd Font"

autocmd VimLeavePre * :call system("date > ~/test.txt")


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



" case-insensitive search
set ignorecase

" Add line numbers
set number
set mouse=n

" open current file in github
function! GHOpen()
	let cmd = "gh browse " . expand("%") . ":" . line(".")
	echo system(cmd)
endfunction

command! GHOpen :call GHOpen()


let g:vimwiki_list = [ 
			\ {'path': '~/my_site/', 'path_html': '~/public_html/', 'syntax': 'markdown', 'ext': '.md'},
			\ ]

" prompt when closing buffer with unsaved changes
" https://vi.stackexchange.com/a/5879
set confirm

" keep terminals open even when changing buffers
set hidden

" Set default tab width to 4
set expandtab

" show whitespace
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<

" Plugins will be downloaded under the specified directory.
" vim-plug stuff
call plug#begin()

" Plug 'tpope/vim-surround'
Plug 'tpope/vim-dotenv'


Plug 'fladson/vim-kitty'
" Plug 'pedrohdz/vim-yaml-folds'
" Plug 'gabrielelana/vim-markdown'

Plug 'vimwiki/vimwiki'

" Plug 'preservim/nerdtree'

" open line in github
Plug 'ruanyl/vim-gh-line'

" direnv plugin
Plug 'direnv/direnv.vim'
"
"""""""""""""""
" Python plugins
"""""""""""""""

" git plugin
Plug 'tpope/vim-fugitive'

" lazygit
Plug 'kdheepak/lazygit.nvim'



" Plug 'flazz/vim-colorschemes'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }


Plug 'earthly/earthly.vim', { 'branch': 'main' }

" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'

" Fish support
Plug 'dag/vim-fish'

" editorconfig
Plug 'editorconfig/editorconfig-vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" markdown
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'sh', 'golang', 'go=golang', 'sql', 'js']


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/ruanyl/vim-gh-line
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gh_use_canonical = 1 " open permalink, not branch



""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    PYTHON
""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:loaded_python_provider = 0
let g:loadedpython3_provider=0
"let g:python3_host_prog = "/home/zane/.pyenv/versions/neovim3/bin/python"
"let python_highlight_all=1
"
"" Run python stuff faster
"nnoremap py :!python3 %

" python syntax highlighting
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ | set softtabstop=4
    \ | set shiftwidth=4
    \ | set expandtab
    \ | set autoindent
    \ | set fileformat=unix


""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    FISH
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" From https://github.com/dag/vim-fish
" Set up :make to use fish for syntax checking.
if &shell =~# 'fish$'
    set shell=bash
endif
" compiler fish

" Set this to have long lines wrap inside comments.
" setlocal textwidth=79

" Enable folding of block structures in fish.
setlocal foldmethod=expr


