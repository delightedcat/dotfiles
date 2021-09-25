
" some basic settings..
syntax on
set tabstop=4
set expandtab
set autoindent
set shiftwidth=4
set number

" some vim-plug plugins.
call plug#begin()
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'itchyny/lightline.vim'
Plug 'shinchu/lightline-gruvbox.vim'
Plug 'maximbaz/lightline-ale'
call plug#end()

let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_sign_info = '·'
let g:ale_sign_style_error = '·'
let g:ale_sign_style_warning = '·'

let g:ale_linters = { 'cs': ['OmniSharp'] }

" set the hard gruvbox theme before setting up the actual scheme.
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" override the ugly default gruvbox color to match my window manager.
highlight Normal ctermfg=white ctermbg=black

" start NERDTree upon launch.
autocmd VimEnter * NERDTree | wincmd p

" automatically close NERDTree when it is the last open window.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

