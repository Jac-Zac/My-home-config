call plug#begin()
Plug 'preservim/nerdtree'
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'suan/vim-instant-markdown'
call plug#end()

colorscheme nord

" Nord customizations 
let g:nord_cursor_line_number_background = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1

" set cursor after exiting nvim 
set guicursor=

" air-line
let g:airline_powerline_fonts = 1

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
" setlocal spell spelllang=it
set spell
set guicursor=
" posso creare azioni che vengono svolte dopo che ho salvato un file
