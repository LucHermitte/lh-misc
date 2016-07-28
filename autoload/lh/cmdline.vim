"=============================================================================
" File:         autoload/lh/cmdline.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      27th Jul 2016
" Last Update:  27th Jul 2016
"------------------------------------------------------------------------
" Description:
"       Support functions for plugin/cmdline-motions.vim
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cmdline#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cmdline#verbose(...)
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

function! lh#cmdline#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Plugin functions {{{1

" Function: lh#cmdline#move(dir) {{{2
function! lh#cmdline#move(dir) abort
  let cmd = getcmdline()
  let p = lh#cmdline#_new_pos(a:dir)
  call setcmdpos(p)
  return cmd
endfunction

" Function: lh#cmdline#CTRLW() {{{2
function! lh#cmdline#CTRLW() abort
  let p = lh#cmdline#_new_pos('left')
  let cmd = getcmdline()
  let p0 = getcmdpos()
  let cmd2 = cmd[: (p-2)] . cmd[(p0-1) :]
  call setcmdpos(p)
  call s:Verbose("-> %1", cmd2)
  return cmd2
endfunction

" Function: lh#cmdline#clear_line_after() {{{2
function! lh#cmdline#clear_line_after() abort
  let cmd = getcmdline()
  let p = getcmdpos()
  let cmd = lh#encoding#strpart(cmd, 0, p)
  return cmd
endfunction

" Function: lh#cmdline#swap_char() {{{2
" With previous
function! lh#cmdline#swap_char() abort
  let cmd = getcmdline()
  let p = getcmdpos()
  let cmd = substitute(cmd, '\v(.)%'.p.'c(.)', '\2\1', '')
  return cmd
endfunction

" Function: lh#cmdline#swap_word(dir) {{{3
function! lh#cmdline#swap_word(dir) abort
  " todo: move the cursor to the right position...
  let cmd = getcmdline()
  let p = getcmdpos()
  if a:dir == 'right'
    let cmd = substitute(cmd, '\v(\w*%'.p.'c\w+)(\W+)(\w+)', '\3\2\1', '')
  elseif a:dir == 'left'
    let cmd = substitute(cmd, '\v(\w+)(\W+)(\w*%'.p.'c\w+)', '\3\2\1', '')
  endif
  return cmd
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" Function: lh#cmdline#_new_pos(dir) {{{3
function! lh#cmdline#_new_pos(dir) abort
  let cmd = getcmdline()
  let p = getcmdpos()
  call s:Verbose('Moving %1 from %2', a:dir, p)
  if a:dir == 'right'
    let p -= 1
  endif
  let parts = split(cmd, '\v\W+\zs')
  let lens = map(copy(parts), 'lh#encoding#strlen(v:val)')

  let starts = []
  let i = 0
  let l = 0
  while i < len(lens)
    let starts += [l]
    let l += lens[i]
    let i += 1
  endwhile

  let i = lh#list#lower_bound(starts, p)
  call s:Verbose('lower_bound(%1, %2) = %3', starts, p, i)
  if a:dir == 'left'
    " TODO:  case i == 0
    if i == 0
      let word_idx = -1
      let exact = 0
    else
      let exact = starts[i-1] == p - 1
      let word_idx = i - 1 - exact
    endif
  elseif a:dir == 'right'
    " TODO:  case i == len(starts)
    if i >= len(starts)
      let word_idx = i
      let exact = 0
    else
      let exact = starts[i] == p
      let word_idx = i + exact
    endif
  else
    throw "unknow action: " . a:action
  endif
  if word_idx < 0
    let p = 1
  elseif word_idx >= len(starts)
    let p = lh#encoding#strlen(cmd) + 1
  else
    let p = starts[word_idx] + 1
  endif
  call s:Verbose('... to -> %1 (word_idx: %2, exact: %3)', p, word_idx, exact)
  return p
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
