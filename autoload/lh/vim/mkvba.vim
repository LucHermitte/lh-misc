"=============================================================================
" $Id$
" File:         autoload/lh/vim/mkvba.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      18th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Helper function to generate vba files.
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/vim
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
let s:verbose = 0
function! lh#vim#mkvba#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#vim#mkvba#debug(expr)
  return eval(a:expr)
endfunction

" # List of files {{{2
function! lh#vim#mkvba#files(root)
  try 
    " need to ignore a few things not ignored by default
    let ignore = &wildignore
    set wildignore+=*.vba

    " get everything
    let files = lh#path#glob_as_list(a:root, '**/*.*')

    " oddly directories are kept by this call => filter them out
    call filter(files, '!isdirectory(v:val)')

    " remove a:root from all paths (suppose all files are within a different
    " directory)
    let files = lh#path#strip_common(files)
    return files
  finally
    let &wildignore = ignore
  endtry
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
