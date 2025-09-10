"=============================================================================
" File:         autoload/lh/python.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.2.
let s:k_version = 002
" Created:      14th Oct 2024
" Last Update:  10th Sep 2025
"------------------------------------------------------------------------
" Description:
"       Support functions for lh-misc/ftplugin/python_set.vim
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
function! lh#python_set#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#python_set#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#python_set#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

"------------------------------------------------------------------------
" ## Internal functions {{{1

" Function: lh#python_set#_check_with(tool, ...) {{{2
let s:k_tools_default_options = {
      \ 'pylint': ['--disable=fixme']
      \ }
let s:k_tools_remove_options = {
      \ 'mypy': ['--strict']
      \ }

function! s:load_compiler_options(tool) abort
  let tool = matchstr(a:tool, '^\S\+')
  if empty(globpath(&rtp, 'compiler/'.tool.'.vim'))
    return ['', '']
  endif
  let cleanup = lh#on#exit()
        \.restore('&:makeprg')
        \.restore('&:errorformat')
  try
    exe 'compiler '.tool
    let options = substitute(&l:makeprg, printf('^%s ', a:tool), '', '')
    let re_noway = get(s:k_tools_remove_options, tool, [])->join('\|')
    let options = substitute(options, re_noway, '', 'g')
    return [options, &l:errorformat]
  finally
    call cleanup.finalize()
  endtry
endfunction

function! lh#python_set#_check_with(tool, ...) abort
  let options = []
  let where   = lh#option#get('paths.sources')
  for o in a:000
    if o[0] == '-'
      call add(options, o)
    else
      let where = o
    endif
  endfor
  if empty(options)
    let options = lh#option#get(a:tool.'.options', get(s:k_tools_default_options, a:tool, []))
  endif
  let [standard_options, efm] = s:load_compiler_options(a:tool)
  call extend(options, lh#command#split_quote_wise(standard_options))
  let cmd = [ a:tool] + options + [where]
  call lh#btw#build#_compile_with(join(cmd, ' '))
endfunction

" Function: lh#python_set#_test_reformat_ruff(...) {{{3
function! lh#python_set#_test_reformat_ruff(...) abort
  if  &ft != 'python'
    throw "Reformatting is only available on current file that needs to be a Python file, not a " . &ft
  endif
  if winnr('$') > 1
    " Spawn a new tab where the diff will be conducted
    tabnew %
  endif
  let filename = expand('%')
  if empty(filename) || !filereadable(filename)
    throw "Current buffer has no existance of disk!"
  endif
  let cmd = ['ruff', 'format', '--stdin-filename='.filename] + a:000 + ['<', filename]
  let res = lh#os#system(join(cmd, ' '))
  let res = split(res, "\n")
  diffthis
  call lh#buffer#scratch('format://'.filename, 'vnew', res)
  set ft=python
  diffthis

  " Diff clearing on exit
  augroup DiffSaved
    au!
    au BufUnload <buffer> diffoff!
  augroup END
  nnoremap <buffer> q :bw<cr>
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
