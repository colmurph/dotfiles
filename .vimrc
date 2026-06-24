syntax enable
set tabstop=2
set softtabstop=2
set expandtab
set number
set showcmd
set cul
set ruler
hi Cursorline term=none cterm=none ctermbg=7
set backspace=indent,eol,start
set background=dark
colorscheme solarized

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END
