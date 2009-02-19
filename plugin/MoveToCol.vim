"=============================================================================
" $Id$
" File:		plugin/MoveToCol.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	2.0.0
" Created:	02nd Mar 2005
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	Helper to align text
" 
"------------------------------------------------------------------------
" Installation:	
" Drop the file into {rtp}/plugin
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================


"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_MoveToCol") && !exists('g:force_reload_MoveToCol')
  finish 
endif
let g:loaded_MoveToCol = 1
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

: VimrcHelp " [N],mc = move to col number [N]
  nnoremap ,mc :<c-u>call <sid>MoveToCol()<cr>

: VimrcHelp " :'<,'>Align {simple-pattern}
  command! -nargs=1 -range Align <line1>,<line2>call s:Align(<q-args>)

  vnoremap <c-x>M :call <sid>Align(<sid>Comments())<cr>



function! s:MoveToCol()
  let d = v:count - col('.')
  if d > 0
    exe 'normal! '.d."i \<esc>"
  endif
endfunction
  
function! RepeatNChar(times, char)
  let r = ''
  let i = 0
  while i != a:times
    let r = r . a:char
    let i = i + 1
  endwhile 
  return r
endfunction

function! CompleteWithUpToCol(with, column)
  " todo: use repeat with vim7+
  return RepeatNChar( a:column-col('.'), a:with)
endfunction

" todo: move to lib
function! Max(a,b)
  return a:a<a:b ? a:b : a:a
endfunction

function! s:Align(pattern) range
  " todo: test whether 0-sized patterns are used
  " todo: nomagic
  let s_pattern = '\s*\zs'.a:pattern
  let r_pattern = '\s*\ze'.a:pattern

  " 1- Look for the destination column
  "    For the first occurrence on each line, we are taking the rightest one
  let max = 0
  " todo: support the ignore argument of searchpos
  exe a:firstline.','.a:lastline.'g/'.s_pattern.'/let max=Max(max,virtcol(searchpos(s_pattern)))'

  " 2- Align !
  exe a:firstline.','.a:lastline.'s/'.r_pattern.'/\=CompleteWithUpToCol(" ", max)/'
  if &verbose > 0
    echomsg a:firstline.','.a:lastline.'s/'.r_pattern.'/\=CompleteWithUpToCol(" ", max)/'
  endif
endfunction


function! s:Comments()
  " todo: support LaTeX
  return escape(matchstr(&commentstring,'.\{-}\ze%'), '\/*.+[]^$')
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
