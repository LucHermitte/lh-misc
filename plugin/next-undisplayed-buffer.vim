"=============================================================================
" File:         plugin/next-undisplayed-buffer.vim                {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.2.
let s:k_version = 002
" Created:      29th Nov 2015
" Last Update:  10th Mar 2016
"------------------------------------------------------------------------
" Description:
"       Cycle to next undisplayed buffer
"
"       http://vi.stackexchange.com/questions/5643/can-i-cycle-through-buffers-while-skipping-ones-ive-opened
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_next_undisplayed_buffer")
      \ && (g:loaded_next_undisplayed_buffer >= s:k_version)
      \ && !exists('g:force_reload_next_undisplayed_buffer'))
  finish
endif
let g:loaded_next_undisplayed_buffer = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
nnoremap <silent> <expr> <Plug>CycleToNextBuffer (&ft=='qf' ? ":cnewer" : <sid>CycleToNext('after'))."\<CR>"
if !hasmapto('<Plug>CycleToNextBuffer', 'n')
  nmap <silent> <unique> <F12> <Plug>CycleToNextBuffer
endif
nnoremap <silent> <expr> <Plug>CycleToPreviousBuffer (&ft=='qf' ? ":colder" : <sid>CycleToNext('before'))."\<CR>"
if !hasmapto('<Plug>CycleToPreviousBuffer', 'n')
  nmap <silent> <unique> <F11> <Plug>CycleToPreviousBuffer
endif
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«next_undisplayed_buffer».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
" Function: s:CycleToNext(direction) {{{3
function! s:CycleToNext(direction) abort
  let undisplayed_buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && bufwinnr(v:val) == -1')
  if empty(undisplayed_buffers)
    echomsg "No hidden (listed) buffer to jump to"
    return ""
  endif
  if a:direction == 'next'
    let after = filter(copy(undisplayed_buffers), 'v:val > bufnr("%")')
    let buf = empty(after) ? undisplayed_buffers[0] : after[0]
  else
    let before = filter(copy(undisplayed_buffers), 'v:val < bufnr("%")')
    let buf = empty(before) ? undisplayed_buffers[-1] : before[-1]
  endif
  return ':b '.buf
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
