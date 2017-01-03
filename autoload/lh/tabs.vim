"=============================================================================
" File:         autoload/lh/tabs.vim                              {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      1.1.0
let s:k_version = 110
" Created:      03rd Jan 2017
" Last Update:  03rd Jan 2017
"------------------------------------------------------------------------
" Description:
"       Support functions for plugin/lh-tabs.vim
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
function! lh#tabs#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#tabs#verbose(...)
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

function! lh#tabs#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Support functions {{{1
function! lh#tabs#move_to_prev_tab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
      tabprev
    endif
    sp
  else
    close!
    exe "0tabnew"
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

function! lh#tabs#move_to_next_tab()
  "there is only one window
  if tabpagenr('$') == 1 && winnr('$') == 1
    return
  endif
  "preparing new window
  let l:tab_nr = tabpagenr('$')
  let l:cur_buf = bufnr('%')
  if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
      tabnext
    endif
    sp
  else
    close!
    tabnew
  endif
  "opening current buffer in new window
  exe "b".l:cur_buf
endfunc

function! lh#tabs#guitablabel()
  let label = ''
  let bufnrlist = tabpagebuflist(v:lnum)
  " let g:g=bufnrlist + [v:lnum]
  " tab name ?
  if exists('t:lh_gui_tab_label')
    let label .= t:lh_gui_tab_label
  else
    let label .= bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
  endif
  " modified ?
  "    Add '+' if one of the buffers in the tab page is modified
  let modified_buffers = filter(copy(bufnrlist), 'getbufvar(v:val, "&modified")')
  if !empty(modified_buffers)
    let label .= '+'
  endif

  " Append the number of windows in the tab page if there are more than one
  let wincount = tabpagewinnr(v:lnum, '$')
  if wincount > 1
    let label .= ' ('.wincount.')'
  endif
  if !empty(label)
    let label .= ' '
  endif

  " label ?
  return label
endfunction


"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
