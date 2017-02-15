"=============================================================================
" File:         autoload/lh/let_modeline.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      2.0
let s:k_version = '200'
" Created:      15th Feb 2017
" Last Update:  15th Feb 2017
"------------------------------------------------------------------------
" Description:
"       Support functions for plugin/let-modeline.vim
"
"------------------------------------------------------------------------
" History:
"
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#let_modeline#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#let_modeline#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#let_modeline#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API functions {{{1

" Constants {{{2
let s:re_var   = '\s\+\([[:alnum:]:_$]\+\)'
" beware the comments ending characters
let s:re_val   = '\(\%(' . "'[^']*'" . '\|"[^"]*"\|[-a-zA-Z0-9:_.&$]\+\)\)$'
let s:re_other = '^\(.\{-}\)'
let s:re_sub   = s:re_other . s:re_var . '\s*=\s*' . s:re_val

" Function: lh#let_modeline#_parse_line(mtch) {{{2
function! lh#let_modeline#_parse_line(mtch) abort
  call s:Verbose('Parse line `%1`', a:mtch)
  if empty(a:mtch) | return | endif
  let mtch  = a:mtch
  while strlen(mtch) != 0
    let vari = substitute( mtch, s:re_sub, '\2', '' )
    let valu = substitute( mtch, s:re_sub, '\3', '' )
    call s:Verbose("regex: `%1`", s:re_sub)
    call s:Verbose("match: `%1`", mtch)
    call s:Verbose("vari : `%1`", vari)
    call s:Verbose("valu : `%1`", valu)
    if (vari !~ '^[[:alnum:]:_$]\+$') || (valu !~ s:re_val)
      call s:Verbose('Invalid var=value format: %1=%2', vari, valu)
      return
    endif
    " Check : no function !
    if s:FindFunctionCall(valu)
      echohl ErrorMsg
      echo "Found a function call in the assignement: let " . vari . " = " . valu
      echohl None
      return
    endif
    let mtch = substitute( mtch, s:re_sub, '\1', '' )
    call s:Verbose('%1 = %2 --- %3', vari, valu, mtch)
    if exists("b:ModeLine_CallBack")
      exe 'let res = '. b:ModeLine_CallBack . '("'.vari.'","'.valu.'")'
      if res == 1 | return | endif
    endif
    " Else
    let valu = s:unstring(valu)
    call lh#let#to(vari, valu)
  endwhile
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
"
" Internal function dedicated to the recognition of function calls {{{2
function! s:FindFunctionCall(value_str) abort
  let str = substitute(a:value_str, '"[^"]*"', '', 'g')
  let str = substitute(str, "'[^']*'", '', 'g')
  return match(str, '(.*)') != -1
endfunction

function! s:unstring(value) abort " {{{2
  " Don't use `eval()`  is order to not open the box to unwanted evaluations
  let res = substitute(a:value, '\v([''"])(.*)\1', '\2', '')
  return res
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
