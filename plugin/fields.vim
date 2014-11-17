"=============================================================================
" $Id$
" File:         plugin/fields.vim                                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      04th Nov 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Fields handling plugin
"
" Usage:
"       :Field count <sep> "cur line
"       :(%)Field remove <sep> [<field-index>]
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
let s:k_version = 1
if &cp || (exists("g:loaded_fields")
      \ && (g:loaded_fields >= s:k_version)
      \ && !exists('g:force_reload_fields'))
  finish
endif
let g:loaded_fields = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1

command! -nargs=+ -range=% -complete=customlist,lh#fields#_complete
      \ Field call lh#fields#_command(<line1>,<line2>, <f-args>)

" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«fields».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
