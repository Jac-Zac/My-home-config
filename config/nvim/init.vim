call plug#begin()
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
call plug#end()

colorscheme nord

set guicursor=

syntax on
set tabstop=4 softtabstop=4
set smartindent

set nowrap

" set noswapfile
" set nobackup
" set undodir=~/.vim/undodir
" set undofile
set incsearch

" set number how I like them 
set number relativenumber
set hlsearch
set ruler

set syntax=markdown
set spell
" posso creare azioni che vengono svolte dopo che ho salvato un file
