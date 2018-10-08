"=============================================================================
" File:         ftplugin/qf_nospell.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      08th Oct 2018
" Last Update:  08th Oct 2018
"------------------------------------------------------------------------
" Description:
"       Force 'nospell' in qf windows
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_qf_nospell")
      \ && (b:loaded_ftplug_qf_nospell >= s:k_version)
      \ && !exists('g:force_reload_ftplug_qf_nospell'))
  finish
endif
let b:loaded_ftplug_qf_nospell = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local settings {{{2

setlocal nospell

" }}}1
"=============================================================================
" vim600: set fdm=marker:
