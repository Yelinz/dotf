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

"Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.css,*.scss,*.less PrettierAsync

"Ctrl P
set wildignore+=*/tmp/*,*/node_modules/*,*/dist/*,*.so,*.swp,*.zip

"---Python---
"syntastic: check python for errors on save
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_flake8_args ='--doctests --ignore=E221,E222,E251,E272,E241,E203,D100,D101,D102,D103,D104,D105,D106,D107'

"Set Tabs to 4 spaces in python
autocmd Filetype py setlocal tabstop=4
