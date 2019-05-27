"---Basic Configuration---
"Plugin Manager
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'nvie/vim-flake8'
Plug 'vim-syntastic/syntastic'
Plug 'joukevandermaas/vim-ember-hbs'
Plug 'prettier/vim-prettier', {
    \ 'do': 'npm install',
    \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss'] }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'Valloric/YouCompleteMe'
Plug 'ambv/black'
Plug 'tpope/vim-fugitive'
Plug 'jparise/vim-graphql'
call plug#end()

"Basic Sets
set tabstop=2
set softtabstop=0
set expandtab
set shiftwidth=2
set smarttab
set number
set mouse=a
set ttymouse=sgr
set hlsearch
set nowrap
"Disables a sound on esc press when in command mode
set noeb vb t_vb=

"Quality of life remaps
command W w 
command Q q 
command Wa wa
command Wq wq
command Qt tabclose
map <F2> :wa <CR>
inoremap <F2> <C-o>:wa<CR>
"replace currently selected text with default register without yanking it
vnoremap p "_dP

"Highlight Trailing spaces
highlight SpecialKey guifg=#444444 ctermfg=206
set list listchars=tab:»\ ,trail:·,precedes:…,extends:…,nbsp:‗

"NerdTree
let mapleader="ö"
map <leader>f :NERDTreeFind<cr>
map <leader>t :NERDTreeToggle<cr>

"Ctrl P
set wildignore+=*/tmp/*,*/node_modules/*,*/dist/*,*.so,*.swp,*.zip,*.min*,*/php/library/*

"---Python---
"Black config
autocmd BufWritePre *.py Black

"Set Tabs to 4 spaces in python
autocmd Filetype py setlocal tabstop=4


"---PHP---
autocmd Filetype php setlocal noexpandtab
