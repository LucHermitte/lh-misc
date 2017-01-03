"=============================================================================
" File:		lh-tabs.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:	1.1.0
let s:k_version = 110
" Created:	10th Jun 2008
" Last Update:	03rd Jan 2017
"------------------------------------------------------------------------
" Description:
"       Defines helper commands to move a window to the previous/next tab
"       If there was only one tab, a new tab is created on the fly
"
"------------------------------------------------------------------------
" History:
" 	v1.1.0: Using autoload plugin
" 	v1.0.0: Insp. from vimtip 1554
" TODO:		«missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_lh_tabs") && !exists('g:force_reload_lh_tabs'))
  finish
endif
let g:loaded_lh_tabs = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and settings {{{1
command! -nargs=0 MoveToPrevTab    :call lh#tabs#move_to_prev_tab()
command! -nargs=0 MoveToNextTab    :call lh#tabs#move_to_next_tab()
command! -nargs=1 LHSetGUITabLabel :let t:lh_gui_tab_label=<f-args>
set guitablabel=#%N\ %{lh#tabs#guitablabel()}

" :MoveBufferToTab [tabnr] (:e|:sp)
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
