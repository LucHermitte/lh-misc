"=============================================================================
" File:         autoload/lh/pkgconfig.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL v3 with Exception
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      12th Sep 2018
" Last Update:  13th Sep 2018
"------------------------------------------------------------------------
" Description:
"       Support functions for plugin/pkgconfig
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
function! lh#pkgconfig#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#pkgconfig#verbose(...)
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

function! lh#pkgconfig#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#pkgconfig#cmd(command, ...) {{{3
let s:exec = 'pkg-config'
function! lh#pkgconfig#cmd(command, ...) abort
  if a:0 == 0
    return
  else
    let cmd = []
    call s:Verbose('lib: %1', a:000)
    for lib in a:000
      if a:command == '--set-vars'
        let cmd += [s:exec, '--cflags', lib, ';']
              \ +  [s:exec, '--libs-only-L', lib, ';']
              \ +  [s:exec, '--libs-only-l', lib, ';']
              \ +  [s:exec, '--libs-only-other', lib, ';']
      endif
    endfor
    let info = lh#os#system(join(cmd, ' '))
    if v:shell_error
      throw "pkg-config: ".string(info)
    endif
    let cflags = []
    let ldflags = []
    let ldlibs = []
    for i in range(len(a:000))
      let cflags += [info[4*i]]
      let ldflags += [info[4*i+1]] + [info[4*i+3]]
      let ldlibs += [info[4*i+2]]
    endfor
  endif
  echomsg "$CFLAGS = ".join(cflags, ' ')
  echomsg "$LDFLAGS = ".join(ldflags, ' ')
  echomsg "$LDLIBS = ".join(ldlibs, ' ')
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" Function: lh#pkgconfig#_complete(ArgLead, CmdLine, CursorPos) {{{2
function! lh#pkgconfig#_complete(ArgLead, CmdLine, CursorPos) abort
  let [pos, tokens; dummy] = lh#command#analyse_args(a:ArgLead, a:CmdLine, a:CursorPos)

  if 1 == pos
    let res = [ '--version', '--modversion',
          \ '--atleast-pkgconfig-version=VERSION', '--libs', '--static',
          \ '--short-errors', '--libs-only-l', '--libs-only-other',
          \ '--libs-only-L', '--cflags', '--cflags-only-I',
          \ '--cflags-only-other', '--variable=NAME',
          \ '--define-variable=NAME=VALUE', '--exists', '--print-variables',
          \ '--uninstalled', '--atleast-version=VERSION',
          \ '--exact-version=VERSION', '--max-version=VERSION', '--list-all',
          \ '--debug', '--print-errors', '--silence-errors',
          \ '--errors-to-stdout', '--print-provides', '--print-requires',
          \ '--print-requires-private', '--validate', '--define-prefix',
          \ '--dont-define-prefix', '--prefix-variable=PREFIX',
          \ '--set-vars'
          \ ]
  else
    " TODO: find where _completion_loader is installed..
    " Or glob into $PKG_CONFIG_PATH + /usr/lib/pkgconfig...
    let res = lh#command#matching_bash_completion('pkg-config', a:ArgLead)
  endif
  return res
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
