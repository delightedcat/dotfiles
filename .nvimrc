
" Some basic settings..
syntax on
set tabstop=4
set expandtab
set autoindent
set shiftwidth=4
set number

" Some vim-plug plugins.
call plug#begin()
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'itchyny/lightline.vim'
Plug 'shinchu/lightline-gruvbox.vim'
Plug 'maximbaz/lightline-ale'
call plug#end()

" A copy of the original pairs minus the () autocompletion.
let g:AutoPairs={'[':']', '{':'}',"'":"'",'"':'"', "`":"`", '```':'```', '"""':'"""', "'''":"'''"}

let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_sign_info = '·'
let g:ale_sign_style_error = '·'
let g:ale_sign_style_warning = '·'

let g:ale_linters = { 'cs': ['OmniSharp'] }

" Set the hard gruvbox theme before setting up the actual scheme.
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" Override the ugly default gruvbox color to match my window manager.
highlight Normal ctermfg=white ctermbg=black

" Show hidden items in NERDTree by default.
let NERDTreeShowHidden=1

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Automatically refresh NERDTree on buffer write.
autocmd BufWritePost * NERDTreeFocus | execute 'normal R' | wincmd p

" Automatically close NERDTree when it is the last open window.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
