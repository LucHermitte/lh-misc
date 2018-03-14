"=============================================================================
" File:		plugin/MoveToCol.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-misc/>
" Version:	2.0.1
" Created:	02nd Mar 2005
" Last Update:	21st Sep 2017
"------------------------------------------------------------------------
" Description:	Helper to align text
"
"------------------------------------------------------------------------
" Installation:
" Drop the file into {rtp}/plugin
" History:
" 2.0.1: Fix support of multi-bytes characters
"        Simplify, Hide global functions
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

:VimrcHelp " [N],mc = move to col number [N]
nnoremap ,mc :<c-u>call <sid>MoveToCol()<cr>

:VimrcHelp " :'<,'>Align {simple-pattern}
command! -nargs=1 -range Align <line1>,<line2>call s:Align(<q-args>)

xnoremap <c-x>M :call <sid>Align(<sid>Comments())<cr>



function! s:MoveToCol() abort
  let d = v:count - virtcol('.')
  if d > 0
    exe 'normal! '.d."i \<esc>"
  endif
endfunction

function! s:CompleteWithUpToCol(with, column)
  return repeat(a:with, a:column-virtcol('.'))
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
  exe a:firstline.','.a:lastline.'g/'.s_pattern.'/let max=max([max,virtcol(searchpos(s_pattern))])'

  " 2- Align !
  exe a:firstline.','.a:lastline.'s/'.r_pattern.'/\=s:CompleteWithUpToCol(" ", max)/'
  if &verbose > 0
    echomsg a:firstline.','.a:lastline.'s/'.r_pattern.'/\=s:CompleteWithUpToCol(" ", '.max.')/'
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
