set incsearch
set ignorecase
set smartcase
set scrolloff=2
set wildignore=*.swp,*.bak,*.pyc,*.class
set history=1000
set undolevels=1000
set title
set nobackup
set noswapfile
set number
set mouse=nv

map <Esc>[D B
map <Esc>[C W

filetype on
au BufNewFile,BufRead *.conf* set filetype=apache
au BufNewFile,BufRead cvs* set filetype=xml

colorscheme mwm

