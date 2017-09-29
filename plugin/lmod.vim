"=============================================================================
" File:         plugin/lmod.vim                                   {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      29th Sep 2017
" Last Update:  29th Sep 2017
"------------------------------------------------------------------------
" Description:
"       Wrapper to execute Lmode `module` command from vim
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_lmod")
      \ && (g:loaded_lmod >= s:k_version)
      \ && !exists('g:force_reload_lmod'))
  finish
endif
let g:loaded_lmod = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -nargs=+
      \ -complete=customlist,lh#lmod#_complete
      \ Module
      \ echo lh#lmod#module(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
