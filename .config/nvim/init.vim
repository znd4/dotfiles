set nocompatible              " required
filetype off                  " required

" Add Copy and cut from select mode
vmap <C-c> "+y
vmap <C-x> "+c

" nmaps
nmap H 0
nmap L $

autocmd BufEnter *.go syntax sync fromstart


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

" vim merge conflict resolution
Plug 'christoomey/vim-conflicted'

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

" editorconfig
Plug 'editorconfig/editorconfig-vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" markdown
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'sh']

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
let g:go_fmt_command = "goimports"
let g:go_fmt_options = '-local github.com/AspirationPartners'

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

" Trigger configuration. You need to change this to something other than <tab> if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsExpandTrigger="<c-b>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" jedi (for python)
Plugin 'davidhalter/jedi-vim'
" code completion
Plugin 'ycm-core/YouCompleteMe'
" Track the engine.
Plugin 'SirVer/ultisnips'
" Snippets are separated from the engine. Add this if you want them:
Plugin 'honza/vim-snippets'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

