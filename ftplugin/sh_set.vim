"=============================================================================
" $Id$
" File:		sh_set.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	16th Nov 2007
" Last Update:	$Date$
"
" Purpose:	ftplugin for Unix shell (-like) programming
"
"------------------------------------------------------------------------
" Installation:	{rtp}/ftplugin/
" Dependancies:	lh-map-tools (misc_map.vim, common_brackets.vim)
" 
" }}}1
"=============================================================================


" ========================================================================
" Buffer local definitions {{{1
" ========================================================================
" Avoid buffer reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_sh_set_vim') && !exists('g:force_reload_sh_ftp')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_sh_set_vim = 1
 
" }}}2
"------------------------------------------------------------------------
" Options to set {{{2
if !exists('maplocalleader')
  let maplocalleader = ','
endif

" Mappings {{{2
" if {{{3
Inoreabbr <buffer> <silent> if <C-R>=InsertSeq('if ',
      \ '\<c-f\>if [ !cursorhere! ] ; then\n!mark!\nfi!mark!')<cr>

vnoremap <buffer> <silent> <localleader>if 
      \ <c-\><c-n>@=Surround('if [ !cursorhere! ] ; then', 'fi!mark!',
      \ 1, 1, '', 1, 'if ')<cr>
vnoremap <buffer> <silent> <LocalLeader><localleader>if 
      \ <c-\><c-n>@=Surround('if [ ', '!cursorhere! ] ; then\n!mark!\nfi!mark!',
      \ 0, 1, '', 1, 'if ')<cr>
nmap <buffer> <LocalLeader>if V<LocalLeader>if
nmap <buffer> <LocalLeader><LocalLeader>if
      \ <Plug>SH_SelectExpr4Surrounding<LocalLeader><LocalLeader>if
 
" }}}1
" ========================================================================
" Global definitions {{{1
" ========================================================================
" Avoid global reinclusion {{{2
if exists("g:loaded_sh_set_vim") && !exists('g:force_reload_sh_ftp')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_sh_set_vim = 1
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2

" todo: fin a better name for the function
function! SH_SelectExpr4Surrounding()
  " Go to the first non blank character of the line
  :normal! ^
  " Search either the first semin-colon or the end of the line.
  :call search(';\|\s*$', 'c')
  " If we are not at the end of the line
  if getline('.')[col('.')-1] =~ ';\|\s'
    " If it is followed by blanck characters
    if strpart(getline('.'), col('.')) =~ '^\s*$'
      " then trim the ';' (or the space) and every thing after
      exe "normal! \"_d$"
    else
      " otherwise replace the ';' by a newline character, and goto the end of
      " the previous line (where the line has been cut)
      exe "normal! \"_s\n\<esc>k$"
    endif
  endif
  " And then select till the first non blank character of the line
  :normal! v^
endfunction


" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
