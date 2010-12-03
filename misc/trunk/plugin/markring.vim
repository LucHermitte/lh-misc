"=============================================================================
" $Id$
" File:         plugin/markring.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      19th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Emacs markring equivalent:
"       - <c-space> pushes a mark at the current position
"       - <c-x><c-space> goes back to the previous mark and pops it
"
" http://www.developpez.net/forums/d925415/systemes/linux/applications/vim-mark-ring/
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
if &cp || (exists("g:loaded_markring")
      \ && (g:loaded_markring >= s:k_version)
      \ && !exists('g:force_reload_markring'))
  finish
endif
let g:loaded_markring = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1

nnoremap <silent> <Plug>PushMark :call <sid>PushMark()<cr>
if !hasmapto('<Plug>PushMark', '')
  nmap <silent> <c-space> <Plug>PushMark
endif
nnoremap <silent> <Plug>PopMark :call <sid>PopMark()<cr>
if !hasmapto('<Plug>PopMark', '')
  nmap <silent> <c-x><c-space> <Plug>PopMark
endif

" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«markring».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.

let s:marks = []
if !exists('s:tags')
  let s:tags = tempname()
  let &tags .= ','.s:tags
endif

function! s:UpdateTags()
  let lines = []
  let i = 0
  while i != len(s:marks)
    let l = 'MarkRing'.i."\t". (s:marks[i].file) .
	  \ "\t" . ':call setpos(".",'.(string(s:marks[i].pos)).')'
    call add(lines, l)
    let i += 1
  endwhile
  call writefile(lines, s:tags)
  " :exe 'sp '.s:tags
endfunction

function! s:PushMark() " {{{2
  let m = getpos('.')
  call add(s:marks, {'pos':m, 'file':expand('%:p')})
  call s:UpdateTags()
  exe 'tag MarkRing'.(len(s:marks)-1)
  echo "mark pushed"
endfunction

function! s:PopMark() " {{{2
  if empty(s:marks) 
    throw "MarkRing: no mark left in the stack"
  endif
  let m = remove(s:marks, -1)
  call s:UpdateTags()
  echo "mark poped"
  " pop!
  pop
endfunction

function! s:ClearRing() " {{{2
  let s:marks = []
  call s:UpdateTags()
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
