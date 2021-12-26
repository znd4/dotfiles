set nocompatible              " required
filetype off                  " required




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

" Plugins will be downloaded under the specified directory.
" vim-plug stuff
call plug#begin()

" git plugin
Plug 'tpope/vim-fugitive'

Plug 'tmsvg/pear-tree'

Plug 'flazz/vim-colorschemes'

Plug 'earthly/earthly.vim', { 'branch': 'main' }

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'

" Fish support
Plug 'dag/vim-fish'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

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

