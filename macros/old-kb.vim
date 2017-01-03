"=============================================================================
" File:         macros/old-kb.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      03rd Jan 2017
" Last Update:  03rd Jan 2017
"------------------------------------------------------------------------
" Description:
"       Old functions that are no longer required
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" Command: Uniq()                                        {{{2
" ---
" Version from: Piet Delport <pjd {at} 303.za {dot} net>
" histdel() does not not in standalone in a command => cf the function
" command! -range=% Uniq
      " \ silent <line1>,<line2>g/^\%<<line2>l\(.*\)\n\1$/d
      " \ | let @/ =  (histdel("search", -1) ? histget("search", -1) : '')
" ---

command! -range=% -nargs=0 Uniq <line1>,<line2>call EmuleUniq()

" Function: EmuleUniq() range
" Use: As it is a `range' function, call it with:
"       :%call EmuleUniq()
"       :'<,'>call EmuleUniq()
"       :3,6call EmuleUniq()
"       etc
function! EmuleUniq() range
  let l1 = a:firstline
  let l2 = a:lastline
  if l1 < l2
    " Version1 from: Preben 'Peppe' Guldberg <peppe {at} xs4all {dot} nl>
    " silent exe l1 . ',' . (l2 - 1) . 's/^\(.*\)\%(\n\%<' . (l2 + 1)
          " \ . 'l\1$\)\+/\1/e'

    " Version from: Piet Delport <pjd {at} 303.za {dot} net>
    " silent exe l1.','l2.'g/^\%<'.l2.'l\(.*\)\n\1$/d'

    " Version1 from: Preben & Piet
    " <line1>,<line2>-g/^\(.*\)\n\1$/d
    silent exe l1.','l2.'-g/^\(.*\)\n\1$/d _'

    call histdel('search', -1)          " necessary
    " let @/ = histget('search', -1)    " useless within a function
  endif
endfunction

" Based on the initial version proposed on the Vim ML by
" Thomas Köhler <jean-luc {at} picard.franken {dot} de>
function! EmuleUniq0() range
  let l = a:firstline
  let e = a:lastline
  let crt = getline(l)          " current line
  while l < e                   " while we're not on the last line
    let l2 = l + 1                      " look next line
    let nxt = getline(l2)               " -- idem
    while (crt == nxt) && (l2<=e)       " while checked line matches current one
      let l2 = l2 + 1                           " ... check next line
      let nxt = getline(l2)
    endwhile
    let l2 = l2 - 1
    if l2 != l                          " if there is more than one occurence
      silent exe (l+1).','.l2.'delete _' |      " delete the redundant lines
      let e = e - (l2 - l)                      " correct the last line number
    endif
    let l = l + 1                       " go to the next line
    let crt = nxt                       " update the current line
  endwhile                      " and endloop ...
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: EmuleSort() range                            {{{2
" Use: As it is a `range' function, call it with:
"       :%call EmuleSort()
"       :'<,'>call EmuleSort()
"       :3,6call EmuleSort()
"       etc
" Based on Robert Webb version (from Vim's documentation)
" Required as Microsoft's sort.exe is not case sensitive since MsDos 3.0 ...
" (smart move!)
" command! -range=% -nargs=0 Sort       <line1>,<line2>call EmuleSort('Strcmp')

func! Strcmp(str1, str2)
  if     (a:str1 < a:str2) | return -1
  elseif (a:str1 > a:str2) | return 1
  else                     | return 0
  endif
endfunction

" internal recursive function
func! s:SortR(start, end, cmp)
  if (a:start >= a:end) | return | endif
  let partition = a:start - 1
  let middle = partition
  let partStr = getline((a:start + a:end) / 2)
  let i = a:start
  while (i <= a:end)
    let str = getline(i)
    exec "let result = " . a:cmp . "(str, partStr)"
    if (result <= 0)
      " Need to put it before the partition.  Swap lines i and partition.
      let partition = partition + 1
      if (result == 0)
        let middle = partition
      endif
      if (i != partition)
        let str2 = getline(partition)
        call setline(i, str2)
        call setline(partition, str)
      endif
    endif
    let i = i + 1
  endwhile

  " Now we have a pointer to the "middle" element, as far as partitioning
  " goes, which could be anywhere before the partition.  Make sure it is at
  " the end of the partition.
  if (middle != partition)
    let str = getline(middle)
    let str2 = getline(partition)
    call setline(middle, str2)
    call setline(partition, str)
  endif
  call s:SortR(a:start, partition - 1, a:cmp)
  call s:SortR(partition + 1, a:end, a:cmp)
endfunc

function! EmuleSort(cmp) range
  silent call s:SortR(a:firstline, a:lastline, a:cmp)
endfunction
" }}}2
"
command! -range=% -nargs=* -complete=function Sort
      \ <line1>,<line2>call s:BISortWrap(<f-args>)

" Function: BISort() range -- by Piet Delport            {{{2
function! s:BISortWrap(...) range                " {{{3
  if (a:0 == 1)
    if !exists('*'.a:1)
      echoerr a:1 . ' is not a valid function name!'
    else
      silent call s:BISort(a:firstline, a:lastline, a:1)
    endif
  elseif a:0 > 1
    echoerr 'Too many arguments!'
  else
    silent call s:BISort2(a:firstline, a:lastline)
  endif
endfunction

function! s:BISort(start, end, cmp)              " {{{3
  let compare_ival_mid = 'let diff = '.a:cmp.'(i_val, getline(mid))'
  let i = a:start + 1
  while i <= a:end
    " find insertion point via binary search
    let i_val = getline(i)
    let lo = a:start
    let hi = i
    while lo < hi
      let mid = (lo + hi) / 2
      exec compare_ival_mid
      if diff < 0
        let hi = mid
      else
        let lo = mid + 1
        if diff == 0 | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfunction

function! s:BISort2(start, end)                  " {{{3
  let i = a:start + 1
  while i <= a:end
    " find insertion point via binary search
    let i_val = getline(i)
    let lo = a:start
    let hi = i
    while lo < hi
      let mid = (lo + hi) / 2
      let mid_val = getline(mid)
      if i_val < mid_val
        let hi = mid
      else
        let lo = mid + 1
        if i_val == mid_val | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfunction

"}}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
