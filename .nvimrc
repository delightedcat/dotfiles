
" -----------------------------------
" PLUGINS
" -----------------------------------
call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'SirVer/ultisnips'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" -----------------------------------
" SETTINGS
" -----------------------------------
set encoding=utf-8
scriptencoding utf-8

syntax enable
filetype plugin indent on

set tabstop=4
set expandtab
set autoindent
set shiftwidth=4
set textwidth=80
set cmdheight=2
set number
set ruler
set mouse=a
set autochdir
set updatetime=300

" -----------------------------------
" COLORSCHEME
" -----------------------------------
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
" Override gruvbox's background with a custom background color.
highlight Normal ctermfg=white ctermbg=black

" -----------------------------------
" NERDTREE
" -----------------------------------
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

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

" -----------------------------------
" COC
" -----------------------------------
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
