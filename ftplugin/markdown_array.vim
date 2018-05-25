"=============================================================================
" File:         ftplugin/markdown_array.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL w/ exception
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      25th May 2018
" Last Update:  25th May 2018
"------------------------------------------------------------------------
" Description:
"       Utilities to modify arrays
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_markdown_array")
      \ && (b:loaded_ftplug_markdown_array >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_array'))
  finish
endif
let b:loaded_ftplug_markdown_array = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=+ -complete=customlist,lh#markdown#array#_complete -range=%
      \ Array
      \ call lh#markdown#array#_command(<line1>, <line2>, <f-args>)

"=============================================================================
" Global Definitions {{{1
" Functions }}}2
"------------------------------------------------------------------------
" }}}1
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
