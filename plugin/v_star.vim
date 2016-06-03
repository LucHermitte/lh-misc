"=============================================================================
" File:		plugin/v_star.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:	0.0.4
" Created:	30th Mar 2009
" Last Update:	03rd Jun 2016
"------------------------------------------------------------------------
" Description:
"	Now v_* searches for the current selection
"
"------------------------------------------------------------------------
" Installation:
" - Requires lh-vim-lib
" - Drop into {rtp}/plugin
" History:
" 	v0.0.4:	Newlines are correctly searched
" 	v0.0.3:	The mappings now exclude SELECT-mode
" 	v0.0.2:	Special characters escaped
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_v_star") && !exists('g:force_reload_v_star'))
  finish
endif
let g:loaded_v_star = '003'
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1

xnoremap <silent> * <c-\><c-n>/<c-r>=substitute(escape(lh#visual#selection(), '/\^$*.[~'), "\n", '\\n', "g")<cr><cr>
xnoremap <silent> # <c-\><c-n>?<c-r>=substitute(escape(lh#visual#selection(), '/\^$*.[~'), "\n", '\\n', "g")<cr><cr>

" Commands and Mappings }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
