" vimtip # 1030

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | 1delete_
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
  " clear diffmode when wiping out/unloading the diff buffer
  augroup DiffSaved
    au!
    au BufUnload <buffer> diffoff!
  augroup END
  nnoremap <buffer> q :bw<cr>
endfunction
com! DiffSaved call s:DiffWithSaved()
