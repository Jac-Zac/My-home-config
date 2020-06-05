call plug#begin()
Plug 'arcticiestudio/nord-vim'
call plug#end()

colorscheme nord
filetype indent on
set smartindent
autocmd BufRead,BufWritePre *.sh normal gg=G
set tabstop=2
set shiftwidth=2
set expandtab
set ai
set number relativenumber
set hlsearch
set ruler
