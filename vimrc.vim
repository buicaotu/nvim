"NVIM Config

" Use clipboard instead of * register
" set clipboard+=unnamedplus
set ignorecase " Search ignore case by default
set smartcase " Use case sensitive when there is capital letter
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab "expand tabs to spaces
" let mapleader=","
set mouse=a " Use mouse
" set number " Show line number
set list
set listchars=tab:>\ ,trail:~,nbsp:+,eol:$
" Default 4000, time for plugin to update
set updatetime=500
" set timeoutlen=500

" FZF
" Use fd as the search engine
" Ignore .git, follow symbolic links 
let $FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
"Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
" 'previous-history' instead of 'down' and 'up'.
let g:fzf_history_dir = '~/.local/share/fzf-history'

"  Window resize
" ----------------------------------------------------
noremap <silent> <M-Left> :vertical resize -5<CR>
noremap <silent> <M-Right> :vertical resize +5<CR>
noremap <silent> <M-Down> :resize -5<CR>
noremap <silent> <M-Up> :resize +5<CR>

" Git conflict highlight
let g:conflict_marker_highlight_group = ''
highlight ConflictMarkerBegin ctermbg=34 
highlight ConflictMarkerOurs ctermbg=22  
highlight ConflictMarkerTheirs ctermbg=27 
highlight ConflictMarkerEnd ctermbg=39 
highlight ConflictMarkerCommonAncestorsHunk ctermbg=yellow


