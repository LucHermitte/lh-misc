"=============================================================================
" File:         autoload/lh/lmod.vim                              {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      29th Sep 2017
" Last Update:  29th Sep 2017
"------------------------------------------------------------------------
" Description:
"       Support functions for plugin/lmod
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
function! lh#lmod#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#lmod#verbose(...)
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

function! lh#lmod#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#lmod#module(command, [options]) {{{2
function! lh#lmod#module(command, ...) abort
  let env = {}
  let env.__shebang  = '/bin/env bash'
  let commands = [ join([$LMOD_CMD, 'bash', a:command]+a:000, ' ')]
  let script = lh#os#new_runner_script(commands, env)
  let s_outputs = script.run()
  let l_outputs = split(s_outputs, "\n")
  " ignore export lines
  call filter(l_outputs, 'v:val !~ "^export"')

  " TODO: bash instruction end with a ";"
  " process var=value
  let first_instruction = match(l_outputs, '\v^.*;$')
  let messages = first_instruction<=0 ? [] : remove(l_outputs, 0, first_instruction-1)
  let [instructions, unknown] = lh#list#separate(l_outputs, 'v:val =~ "\\v^\\w+\\=\\S+|^unset"')

  call s:Verbose('%1', messages)
  call s:Verbose('=======')
  call s:Verbose('%1', instructions)
  call map(instructions, 'substitute(v:val, ";$", "", "")')
  for instr in instructions
    if instr =~ '^unset.*'
      " TODO: fix the day vim supports unsetting
      let env = instr[6:].'=""'
    else
      let env = instr
    endif
    call s:Verbose('let $'.env)
    execute 'let $'.env
  endfor
  call s:Verbose('=======')
  call s:Verbose('%1', unknown)
  return join(messages, "\n")
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Function: lh#lmod#_complete(ArgLead, CmdLine, CursorPos) {{{2
function! lh#lmod#_complete(ArgLead, CmdLine, CursorPos) abort
  let [pos, tokens; dummy] = lh#command#analyse_args(a:ArgLead, a:CmdLine, a:CursorPos)

  if 1 == pos
    let res = ['load', 'unload', 'purge', 'list', 'av', 'show']
  else
    " TODO: find where _completion_loader is installed..
    let res = lh#command#matching_bash_completion('module', a:ArgLead)
  endif
  return res
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
