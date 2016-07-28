"=============================================================================
" File:         plugin/cmdline-motions.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      27th Jul 2016
" Last Update:  28th Jul 2016
"------------------------------------------------------------------------
" Description:
"
" Command line editing commands in emacs style:
"   <C-A>           : home
"   <C-F>           : right
"   <C-B>           : left
"   <C-K>           : clear line after cursor
"   <C-T>           : Swap character
"   <C-G>w          : Move currnt word right
"   <C-G>W          : Move currnt word left
"   <ESC>b          : back WORD
"   <ESC>f          : forward WORD
"   <ESC><C-H>      : <C-W>
"   <M-b> <M-Left>  : back word
"   <M-f> <M-Right> : forward word
"   <M-d>           : delete word after cursor
" "   <C-U>         : Clear whole line
" "   <C-BS>        : Clear till the beginning of the line
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_cmdline_motions")
      \ && (g:loaded_cmdline_motions >= s:k_version)
      \ && !exists('g:force_reload_cmdline_motions'))
  finish
endif
let g:loaded_cmdline_motions = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
  cnoremap <C-A> <Home>
  cnoremap <C-F> <Right>
  cnoremap <C-B> <Left>
  cnoremap <ESC>b <S-Left>
  cnoremap <ESC>f <S-Right>
  cnoremap <ESC><C-H> <C-W>
  " cnoremap <C-U> <End><C-U>
  " cnoremap <C-BS> <C-U>
  cnoremap <C-K>     <c-\>elh#cmdline#clear_line_after()<cr>
  cnoremap <C-T>     <c-\>elh#cmdline#swap_char()<cr>
  cnoremap <C-G>w    <c-\>elh#cmdline#swap_word('right')<cr>
  cnoremap <C-G>W    <c-\>elh#cmdline#swap_word('left')<cr>
  cnoremap <M-w>     <c-\>elh#cmdline#CTRLW()<cr>
  cnoremap <M-b>     <c-\>elh#cmdline#move('left')<cr>
  cnoremap <M-f>     <c-\>elh#cmdline#move('right')<cr>
  cnoremap <M-left>  <c-\>elh#cmdline#move('left')<cr>
  cnoremap <M-right> <c-\>elh#cmdline#move('right')<cr>

" Commands and Mappings }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
