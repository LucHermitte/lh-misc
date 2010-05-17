"=============================================================================
" $Id$
" File:		plugin/v_star.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	0.0.1
" Created:	30th Mar 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
"	Now v_* searches for the current selection
" 
"------------------------------------------------------------------------
" Installation:	
" - Requires lh-vim-lib
" - Drop into {rtp}/plugin
" History:	
" TODO:		«missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_v_star") && !exists('g:force_reload_v_star'))
  finish
endif
let g:loaded_v_star = '001'
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1

vnoremap <silent> * <c-\><c-n>/<c-r>=lh#visual#selection()<cr><cr>
vnoremap <silent> # <c-\><c-n>?<c-r>=lh#visual#selection()<cr><cr>

" Commands and Mappings }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
