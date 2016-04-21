"=============================================================================
" File:           autoload/lh/tex/fold.vim                          {{{1
" Initial Author: Johannes Zellner <johannes@zellner.org>
" URL:            http://www.zellner.org/vim/fold/tex.vim
" Maintainer:     Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"                 <URL:http://github.com/LucHermitte/lh-misc>
" Version:        0.0.1.
let s:k_version = 001
" Created:      04th Apr 2016
" Last Update:  04th Apr 2016
"------------------------------------------------------------------------
" Description:
"       Folding for (La)TeX
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#tex#fold#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#tex#fold#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr)
  call lh#log#this(a:expr)
endfunction

function! s:Verbose(expr)
  if s:verbose
    call s:Log(a:expr)
  endif
endfunction

function! lh#tex#fold#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Options functions {{{1
function! s:opt_fold_blank()
  return lh#option#get('fold_options.fold_blank', 0)
endfunction

" ## Exported functions {{{1
" Function: lh#tex#fold#expr(line) {{{2
function! lh#tex#fold#expr(line) abort
    " remove comments
    let line = substitute(getline(a:line), '\(^%\|\s*[^\\]%\).*$', '', 'g')
    " let level = s:TexFoldContextFlat(line)
      let level = s:TexFoldContextWithDepth(line)
    if level
        exe 'return ">'.level.'"'
    elseif line =~ '.*\\begin\>.*'
        return 'a1'
    elseif line =~ '.*\\end\>.*'
        return 's1'
    else
        return '='
    endif
endfunction

" Function: lh#tex#fold#text(line) {{{2
function! lh#tex#fold#text() abort
  return lh#tex#fold#_text(v:foldstart)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Fold detection {{{2
" Function: s:TexFoldContextWithDepth(line) {{{3
fun! s:TexFoldContextWithDepth(line)
  if a:line =~ '\\part\>'               | return 1
  elseif a:line =~ '\\chapter\>'        | return 2
  elseif a:line =~ '\\section\>'        | return 3
  elseif a:line =~ '\\subsection\>'     | return 4
  elseif a:line =~ '\\subsubsection\>'  | return 5
  elseif a:line =~ '\\paragraph\>'      | return 6
  elseif a:line =~ '\\subparagraph\>'   | return 7
  else                                  | return 0
  endif
endfun

" Function: ! s:TexFoldContextFlat(line) {{{3
fun! s:TexFoldContextFlat(line)
  if a:line =~ '\\\(part\|chapter\|\(sub\)\+section\|\(sub\)\=paragraph\)\>'
    return 1
  else
    return 0
  endif
endfun

" # Fold text {{{2
" Function: lh#tex#fold#_text(lnum) {{{3
function! lh#tex#fold#_text(lnum) abort
  " let lnum = s:NextNonCommentNonBlank(a:lnum, s:opt_fold_blank())
  let lnum = a:lnum
  let line0 = getline(lnum)
  if line0 =~ '\v\\(part|chapter|(sub){,2}section|(sub)=paragraph)'
    " TODO: print number of frames ?
    return repeat('  ', s:TexFoldContextWithDepth(line0)-1) . '+- '.line0
  elseif line0 =~ '\v\\begin\{frame\}'
    " Search for title
    let title = line0
    while lnum != line('$')
      let line = getline(lnum)
      if line =~ '\v\\end\{frame\}'
        break
      elseif line =~ '\\frametitle'
        let title = repeat('  ', foldlevel(a:lnum)). "+- Frame: ".matchstr(line, '\\frametitle{\zs.*\ze}')
      elseif line =~ '\\framesubtitle'
        let title .= ' -> ' . matchstr(line, '\\framesubtitle{\zs.*\ze}')
        return title " nothing more to add!
      endif
      let lnum = s:NextNonCommentNonBlank(lnum+1, s:opt_fold_blank())
    endwhile
    return title
  endif
  return line0
endfunction

" Misc {{{2
" Function: s:IsACommentLine(lnum)         {{{2
function! s:IsACommentLine(lnum, or_blank) abort
  let line = getline(a:lnum)
  if line =~ '^\s*%'. (a:or_blank ? '\|^\s*$' : '')
    " C++ comment line / empty line => continue
    return 1
  elseif line =~ '\S.*%'
    " Not a comment line => break
    return 0
  else
    let id = synIDattr(synID(a:lnum, strlen(line)-1, 0), 'name')
    return id =~? 'comment'
  endif
endfunction

" Function: s:NextNonCommentNonBlank(lnum) {{{2
" Comments => ignore them:
" the fold level is determined by the code that follows
function! s:NextNonCommentNonBlank(lnum, or_blank) abort
  let lnum = a:lnum
  let lastline = line('$')
  while (lnum <= lastline) && s:IsACommentLine(lnum, a:or_blank)
    let lnum += 1
  endwhile
  return lnum
endfunction


"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
