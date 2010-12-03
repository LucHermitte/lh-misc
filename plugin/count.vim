"=============================================================================
" $Id$
" File:         plugin/count.vim                                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      «0.0.1»
" Created:      28th Sep 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/plugin
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:k_version = 001
if &cp || (exists("g:loaded_count")
      \ && (g:loaded_count >= s:k_version)
      \ && !exists('g:force_reload_count'))
  finish
endif
let g:loaded_count = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -nargs=1 -bang -range Count <line1>,<line2>call s:Count("<bang>", <f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
function! s:Count(bang, param) range
  let pos = getpos('.')
  let inverse = a:bang == '!'
  let cmd = inverse ? 'v' : 'g'
  let s:c = 0
  try 
    exe a:firstline.','.a:lastline.cmd.'#'.escape(a:param, '#').'#let s:c += 1'
  finally
    call setpos('.', pos)
  endtry
  echo s:c
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
