set nocompatible              " required
filetype off                  " required

" Add Copy and cut from select mode
vmap <C-c> "+y
vmap <C-x> "+c

" Add line numbers
set number

" prompt when closing buffer with unsaved changes
" https://vi.stackexchange.com/a/5879
set confirm

" keep terminals open even when changing buffers
set hidden

" Set default tab width to 4
set tabstop=4
set shiftwidth=4

" show whitespace
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<

" Plugins will be downloaded under the specified directory.
" vim-plug stuff
call plug#begin()

" direnv plugin
Plug 'direnv/direnv.vim'

" python black plugin
" https://black.readthedocs.io/en/stable/integrations/editors.html#vim
Plug 'psf/black', { 'branch': 'stable' }

" async autocheck syntax
Plug 'dense-analysis/ale'

" git plugin
Plug 'tpope/vim-fugitive'

Plug 'tmsvg/pear-tree'

Plug 'flazz/vim-colorschemes'

Plug 'earthly/earthly.vim', { 'branch': 'main' }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'

" Fish support
Plug 'dag/vim-fish'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    ALE
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fixers = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    PYTHON
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_host_prog = "/home/zane/.pyenv/versions/neovim3/bin/python"

" black autoformat on save
autocmd BufWritePre *.py execute ':ALEFix'

" black ale
let g:ale_fixers.python = ['black']

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    FISH
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" From https://github.com/dag/vim-fish
" Set up :make to use fish for syntax checking.
syntax enable
filetype plugin indent on
if &shell =~# 'fish$'
    set shell=bash
endif
" compiler fish

" Set this to have long lines wrap inside comments.
setlocal textwidth=79

" Enable folding of block structures in fish.
setlocal foldmethod=expr

" color scheme
colorscheme darkglass

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

