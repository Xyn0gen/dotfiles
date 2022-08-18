set rnu nu
setglobal tabstop=4 shiftwidth=4 expandtab
" filetype plugin indent on
" set clipboard=unnamed
set mouse=a
set list 
set listchars=tab:\ ›,lead:·,trail:·
set formatoptions-=cro
set noshowmode

autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python' shellescape(@%, 1)<CR>


call plug#begin('~/appdata/local/nvim-data/site/plugged')
Plug 'sainnhe/gruvbox-material'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdtree'

" Plug 'svermeulen/vim-cutlass'
Plug 'Yggdroot/indentLine'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'neoclide/coc.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-repeat'
call plug#end()

if has('termguicolors')
  set termguicolors
endif

" let g:sonokai_style = 'default'
" let g:sonokai_enable_italic = 0
" let g:sonokai_disable_italic_comment = 1
" colorscheme sonokai
" let g:lightline = { 'colorscheme': 'sonokai' }

set background=dark
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_enable_italic = 0
let g:gruvbox_material_disable_italic_comment = 1
let g:gruvbox_material_foreground = 'material'
colorscheme gruvbox-material
let g:lightline = { 'colorscheme': 'gruvbox_material' }

nmap <F2> :NERDTreeToggle<CR>
augroup filetype_nerdtree
    au!
    au FileType nerdtree call s:disable_lightline_on_nerdtree()
    au WinEnter,BufWinEnter,TabEnter * call s:disable_lightline_on_nerdtree()
augroup END
fu s:disable_lightline_on_nerdtree() abort
    let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
    call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
endfu
let g:NERDTreeChDirMode = 2

noremap <leader> "*
imap <C-S-CR> <ESC>O
imap <C-CR> <ESC>o
nmap <C-S-CR> O<ESC>
nmap <C-CR> o<ESC>

let g:indentLine_char_list = ['|']
let g:indentLine_color_gui = '#3c3846'

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" let g:neovide_remember_window_size=v:true
set guifont=Cascadia\ Code\ PL:h12
let g:neovide_refresh_rate=144
let g:neovide_cursor_animation_length=0
