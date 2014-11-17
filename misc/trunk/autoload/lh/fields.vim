"=============================================================================
" $Id$
" File:         autoload/lh/fields.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      04th Nov 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Fields handling plugin (support functions)
"
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 1
function! lh#fields#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#fields#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#fields#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Subcommands list {{{2
let s:subcommands = {
      \ 'count': function('lh#fields#_show_count'),
      \ 'remove': function('lh#fields#_remove'),
      \}

" Function: lh#fields#_complete(ArgLead, CmdLine, CursorPos) {{{2
let s:command = 'Fi\%[eld]'
function! lh#fields#_complete(ArgLead, CmdLine, CursorPos) abort
  let cmd = matchstr(a:CmdLine, s:command)
  let cmdpat = '^'.cmd

  let tmp = substitute(a:CmdLine, '\s*\S\+', 'Z', 'g')
  let pos = strlen(tmp)
  let lCmdLine = strlen(a:CmdLine)
  let fromLast = strlen(a:ArgLead) + a:CursorPos - lCmdLine
  " The argument to expand, but cut where the cursor is
  let ArgLead = strpart(a:ArgLead, 0, fromLast )
  if 0
    call confirm( "a:AL = ". a:ArgLead."\nAl  = ".ArgLead
          \ . "\nx=" . fromLast
          \ . "\ncut = ".strpart(a:CmdLine, a:CursorPos)
          \ . "\nCL = ". a:CmdLine."\nCP = ".a:CursorPos
          \ . "\ntmp = ".tmp."\npos = ".pos
          \ . "\ncmd = ".cmd
          \, '&Ok', 1)
  endif

  if cmd != 'Field'
    throw "Completion option called with wrong command"
  endif

  if     2 == pos
    return filter(keys(s:subcommands), 'v:val =~ '.string(ArgLead))
  elseif 3 == pos
    let subcommand = matchstr(a:CmdLine, '^'.s:command.'\s\+\zs\S\+\ze')
  endif
  return []
endfunction

" Function: lh#fields#_command(...) {{{2
function! lh#fields#_command(fl, ll, ...) abort
  if a:0 == 0
    call lh#common#error_msg(':Fields: missing argument, try '.string(keys(s:subcommands)))
    return
  endif

  let subcommand = a:1
  if !has_key(s:subcommands, subcommand)
    call lh#common#error_msg(':Fields: invalid subcommand `'.subcommand.'`, try '.string(keys(s:subcommands)))
  else
    let pos = getcurpos()
    call call (s:subcommands[subcommand], [a:fl, a:ll] + a:000[1:])
    call setpos('.', pos)
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" # Interface functions {{{2

" Function: lh#fields#_show_count() {{{3
function! lh#fields#_show_count(fl, ll, sep)
  let cnt = lh#fields#_count(a:sep)

  echo "Cursor is on the ".cnt."-th field"
        " \ . (lin[col-1]==a:sep ? " (and on the separator of the next field)": "") 
endfunction

" Function: lh#fields#_remove(sep, ...) {{{3
function! lh#fields#_remove(fl, ll, sep, ...) abort
  let cnt = a:0 > 0 ? (a:1) : lh#fields#_count(a:sep)

  echo "Removing ".cnt."-th field on [".a:fl.','.a:ll.']'
  if cnt == 0
    silent exe a:fl.','.a:ll.'s/^[^'.a:sep.']*'.a:sep.'//'
  else
    silent exe a:fl.','.a:ll.'s/^[^'.a:sep.']*\('.a:sep.'[^'.a:sep.']*\)\{'.(cnt-1).'}\zs'.a:sep.'[^'.a:sep.']*//'
  endif
endfunction

" # toolbox {{{2
" " Function: lh#fields#_count(sep) {{{3
function! lh#fields#_count(sep)
  let col = col('.')
  let lin = getline('.')
  let str = lin[0:col-1]
  let str = substitute(str, '[^'.a:sep.']', '', 'g')
  let cnt = len(str) - (lin[col-1]==a:sep ? 1 : 0)
  return cnt
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
