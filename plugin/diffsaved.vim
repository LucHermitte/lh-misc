" vimtip # 1030

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | 1delete_
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
