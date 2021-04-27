call plug#begin()
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'suan/vim-instant-markdown'
Plug 'preservim/nerdtree'
Plug 'donRaphaco/neotex', { 'for': 'tex' }
call plug#end()

" Nord customizations
let g:nord_cursor_line_number_background = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1

colorscheme nord " set color schema to nord

" air-line
let g:airline_powerline_fonts = 1

" vim instant markdown configuration 
let g:instant_markdown_open_to_the_world = 1 " open the markdown to people on my same network
let g:instant_markdown_mathjax = 1 " allows you to render Latex (this is essential)

" Latex for nvim 
let g:neotex_enabled = 2
let g:neotex_delay = 500

set tabstop=4 
set shiftwidth=4
set smartindent
set autoindent
set nowrap
set incsearch
set syntax=markdown

" set number how I like them
set number relativenumber
set hlsearch
set ruler

" set languages with fn
" default is English
set spell
map <F1> :setlocal spell! spelllang=en<CR>
map <F2> :setlocal spell! spelllang=it<CR>

" Nerd tree
map <F3> :NERDTree<CR>

" Compiling latex
map <F4> :NeoTex<CR>
