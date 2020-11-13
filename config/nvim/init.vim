call plug#begin()
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'suan/vim-instant-markdown'
call plug#end()

colorscheme nord

set guicursor=

syntax on
set shiftwidth=4 
set tabstop=4 
set softtabstop=4
set autoindent
set smartindent
set nowrap
set incsearch
" set number how I like them
set number relativenumber
set hlsearch
set ruler
set syntax=markdown
set spell
" setlocal spell spelllang=it
setlocal spell spelllang=en
set guicursor=
" posso creare azioni che vengono svolte dopo che ho salvato un file
