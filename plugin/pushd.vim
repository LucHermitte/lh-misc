"=============================================================================
" File:         plugin/pushd.vim                                  {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL v3
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      28th Sep 2020
" Last Update:  29th Sep 2020
"------------------------------------------------------------------------
" Description:
"       Implements :Pushd, :Popd, :Dirs and :Go
"
"       Inspired from D. Ben Knoble answer to
"       https://vi.stackexchange.com/a/27487/626
"
"------------------------------------------------------------------------
" TODO:
" * Implement other bash's pushd parameters
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim

if &cp || (exists("g:loaded_pushd")
      \ && (g:loaded_pushd >= s:k_version)
      \ && !exists('g:force_reload_pushd'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_pushd = s:k_version
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1

command! -nargs=? -complete=customlist,s:complete_push Pushd call s:pushd(<f-args>)
command! -nargs=?                                      Popd  call s:popd(<f-args>)
command! -nargs=*                                      Dirs  call s:dirs(<f-args>)
command! -nargs=*                                      Go    call s:go(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«pushd».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
let s:stack = get(s:, 'stack', [])

function! s:complete_push(ArgLead, CmdLine, CursorPos) abort
  if a:ArgLead =~ '^+'
    let res = map(range(1, len(s:stack)), '"+".v:val')
    call filter(res, 'v:val =~ a:ArgLead')
  else
    let res = getcompletion(a:ArgLead, 'dir')
  endif
  return res
endfunction

function! s:pushd(...) abort
  if a:0 == 0
    " swap ~0 and ~1
    let old_1 = s:stack[0]
    let s:stack[0] = getcwd()
    exe 'cd '.old_1
  elseif a:1 =~ '^+\d\+'
    let idx = eval(a:1)
    if idx > len(s:stack)
      throw "There are only ".len(s:stack)." elements in the stack"
    endif
    let st = [getcwd()] + s:stack
    let st = st[idx:] + st[:(idx-1)]
    exe 'cd '.st[0]
    let s:stack = st[1:]
  else
    call insert(s:stack, getcwd())
    exe 'cd '.a:1
  endif
  call s:dirs()
endfunction

function! s:filter_dirs(...) abort
  let dirs = map([getcwd()] + s:stack, '[v:key, v:val]')
  if  a:0 > 0
    let pats = a:000
    " dirs->filter({k,d -> reduce(....
    call filter(dirs, {k, d -> eval(join(map(copy(l:pats), '1+match(d[1], v:val)'), '&&'))})
  endif
  return dirs
endfunction

function! s:dirs(...) abort
  let dirs = call('s:filter_dirs', a:000)
  let list = join(map(copy(dirs), 'printf("%2d -> %s", v:val[0], v:val[1])'), "\n")
  echo list
endfunction

function! s:go(...) abort
  let dirs = call('s:filter_dirs', a:000)
  if len(dirs) == 1
    call s:pushd('+'.dirs[0][0])
  else
    echomsg "Too many directories matching ".join(a:000, ' ')
    call call('s:dirs', a:000)
  endif
endfunction

function! s:popd(...) abort
  let d = remove(s:stack, 0)
  exe 'cd '.d
  call s:dirs()
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
