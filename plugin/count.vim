"=============================================================================
" $Id$
" File:         plugin/count.vim                                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      «0.0.1»
" Created:      28th Sep 2010
" Last Update:  18th Jul 2019
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
" command! -nargs=1 -bang -range Count <line1>,<line2>call s:Count("<bang>", <f-args>, )
command! -nargs=1 -range Count call s:Count2(<f-args>, <line1>,<line2>)
" command! -nargs=1 -range=% Count2 echo eval(join(map(getline(<line1>,<line2>), 'count(v:val, "<args>")'), '+'))
" command! -nargs=1 -range=% Count2 keeppattern <line1>,<line2>s/<args>//gn
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
function! s:Count(bang, param) range abort
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

" Function: s:Count2(param) {{{3
" Not using the usual :function-range to avoid moving the cursor
function! s:Count2(param, firstl, lastl) abort
  let c = []
  " The new syntax requires a more global variable
  " call map(getline(a:firstl, a:lastl), { k,v -> substitute(v, 'line', '\=add(l:c, v)[-1]', 'g')})
  call map(getline(a:firstl, a:lastl), "substitute(v:val, 'line', '\\=add(c, v:val)[-1]', 'g')")
  echo len(c)
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
