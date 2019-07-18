"=============================================================================
" File:         autoload/lh/vim/maintain.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.1.1.
let s:k_version = 011
" Created:      05th Sep 2016
" Last Update:  18th Jul 2019
"------------------------------------------------------------------------
" Description:
"       Support functions for ftplugin/vim/vim_maintain.vim
"
"------------------------------------------------------------------------
" History:
"       v0.1.1: Apply `:Verbose` without argument on the current
"               autoload plugin.
"       v0.0.8: Less (undo-)intrusive timestamp insertion
"       v0.0.7: Auto-remove trailing whitespaces and update "Last Update" on
"               saving
"       v0.0.6: Verbose rewritten to support lh#*#verbose() only, and auto
"               complete.
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#vim#maintain#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#vim#maintain#verbose(...)
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

function! lh#vim#maintain#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

"------------------------------------------------------------------------
" ## Internal functions {{{1
" # Help {{{2
" Function: lh#vim#maintain#_current_help_word() {{{3
function! lh#vim#maintain#_current_help_word() abort
  try
    let isk = &isk
    set isk+=(,:,#,&
    let w = expand('<cword>')
  finally
    let &isk = isk
  endtry
  let w = matchstr(w, '^[:&]\=\k\+(\=')
  if w[-1:] == '('
    let w .= ')'
  elseif w[0] == '&'
    let w = "'".w[1:]."'"
  endif
  return w
endfunction

" # GoVerbose
" Function: lh#vim#maintain#_go_verbose(onoff, ...) {{{3
function! lh#vim#maintain#_go_verbose(onoff, ...) abort
  let onoff = a:onoff != '!'
  let list = a:000
  if empty(list)
    " Let's suppose we are within an autoload plugin
    let p = matchstr(expand('%:p'), '.*/autoload/lh/\zs.*\ze\.vim$')
    if empty(p)
      throw "The current file isn't a autoload/lh plugin"
    endif
    let list = [substitute(p, '/', '#', 'g')]
  endif
  for f in list
    try
      if f =~ '-\+h\%[elp]'
        call lh#common#warning_msg(':Verbose will call `lh#{arg}#verbose(no_bang)`')
        break
      endif
      call s:Verbose('Toogle verbose %2 for lh#%1', f, onoff ? 'on' : 'off')
      call lh#{f}#verbose(onoff)
    catch /.*/
      echomsg v:exception
    endtry
  endfor
endfunction

" Function: lh#vim#maintain#_go_verbose_complete(ArgLead, CmdLine, CursorPos) {{{3
function! lh#vim#maintain#_go_verbose_complete(ArgLead, CmdLine, CursorPos) abort
  call s:Verbose('complete(lead="%1", cmdline="%2", cursorpos=%3)', a:ArgLead, a:CmdLine, a:CursorPos)

  let lh_auto_plugins = lh#path#glob_as_list(&rtp, 'autoload/lh/**/*.vim')
  call map(lh_auto_plugins, 'substitute(v:val, "\\v.*/autoload/lh/(.*)\\.vim", "\\1", "")')
  call map(lh_auto_plugins, 'substitute(v:val, "/", "#", "g")')

  let acceptable_values = filter(copy(lh_auto_plugins), 'v:val =~ a:ArgLead')

  return acceptable_values + ['--help']
endfunction

" Function: lh#vim#maintain#_save_pre_hook() {{{3
if exists('*undotree')
  function! s:must_update_time_stamp() abort
    let ut = undotree()
    call s:Verbose("must_update_time_stamp: %1 < %2 ? %3 (%4)", ut.save_last, ut.save_cur, ut.save_last < ut.save_cur, ut)
    return ut.save_last <= ut.save_cur
  endfunction
else
  function! s:must_update_time_stamp() abort
    return &modified
  endfunction
endif

function! lh#vim#maintain#_save_pre_hook() abort
  let pos = getpos('.')
  let cleanup = lh#on#exit()
        \.register('call setpos(".", '.string(pos).')')
  try
    if lh#option#get('vim_maintain.remove_trailing', 1)
      :silent! %s/\s\+$//
    endif
    if s:must_update_time_stamp()
      cal cursor(0,0)
      let [l,c] = searchpos('\v\clast (changes|update)\s*:\s*\zs', 'n')
      if [l,c] != [0,0]
        let lin = getline(l)
        if lin !~ lh#time#date()
          let new = lin[: (c-2)].lh#time#date()
          silent call setline(l, new)
        endif
      endif
    endif
  finally
    call cleanup.finalize()
  endtry
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
