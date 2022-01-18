set nocompatible              " required
filetype off                  " required

" Add Copy and cut from select mode
vmap <C-c> "+y
vmap <C-x> "+c

" Add line numbers
set number

set mouse=n

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

Plug 'preservim/nerdtree'

" open line in github
Plug 'ruanyl/vim-gh-line'

" direnv plugin
Plug 'direnv/direnv.vim'
"
"""""""""""""""
" Python plugins
"""""""""""""""

" python black plugin
" https://black.readthedocs.io/en/stable/integrations/editors.html#vim
Plug 'psf/black', { 'branch': 'stable' }
Plug 'vim-scripts/indentpython.vim'

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

" ctrlp (used for vim-go motion)
Plug 'ctrlpvim/ctrlp.vim'

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'

" Fish support
Plug 'dag/vim-fish'


" List ends here. Plugins become visible to Vim after this call.
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-go
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 0

let g:go_auto_type_info = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/ruanyl/vim-gh-line
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gh_use_canonical = 1 " open permalink, not branch


""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    ALE
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fixers = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    PYTHON
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:python_host_prog = "/home/zane/.pyenv/versions/neovim3/bin/python"
let python_highlight_all=1


" black autoformat on save
autocmd BufWritePre *.py execute ':ALEFix'

" black ale
let g:ale_fixers.python = ['black']

" python syntax highlighting
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ | set softtabstop=4
    \ | set shiftwidth=4
    \ | set textwidth=89
    \ | set expandtab
    \ | set autoindent
    \ | set fileformat=unix


"python with virtualenv support
python3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  exec(open(activate_this).read(), dict(__file__=activate_this))
EOF

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

" YouCompleteMe
let g:ycm_filetype_blacklist = {
	  \ 'python': 1,
      \}
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf=0

" Point YCM to the Pipenv created virtualenv, if possible
" At first, get the output of 'pipenv --venv' command.
let pipenv_venv_path = system('pipenv --venv')
" The above system() call produces a non zero exit code whenever
" a proper virtual environment has not been found.
" So, second, we only point YCM to the virtual environment when
" the call to 'pipenv --venv' was successful.
" Remember, that 'pipenv --venv' only points to the root directory
" of the virtual environment, so we have to append a full path to
" the python executable.
if v:shell_error == 0
  let venv_path = substitute(pipenv_venv_path, '\n', '', '')
  let g:ycm_python_binary_path = venv_path . '/bin/python'
else
  let g:ycm_python_binary_path = 'python3'
endif


" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" jedi (for python)
Plugin 'davidhalter/jedi-vim'

" code completion
Plugin 'ycm-core/YouCompleteMe'

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

