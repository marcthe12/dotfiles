set all&

set number
set autoindent
set showmatch
set showmode
set errorbells
set belloff=
set title

set swapfile
set directory^=~/.vim/swap//
set writebackup
set nobackup
set backupcopy=auto
if has("patch-8.1.0251")
	set backupdir^=~/.vim/backup//
end
set undofile
set undodir^=~/.vim/undo//

if has('autocmd')
	filetype plugin indent on
endif

if has('syntax') && (&t_Co > 2 || has("gui_running"))
	syntax enable
	if has('extra_search')
		set hlsearch
		set incsearch
	endif
	colorscheme industry
end

if &t_Co > 16 
	set termguicolors
	let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
	let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
end
