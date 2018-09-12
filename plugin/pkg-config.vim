"=============================================================================
" File:         plugin/pkg-config.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL v3 with Exception
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      12th Sep 2018
" Last Update:  12th Sep 2018
"------------------------------------------------------------------------
" Description:
"       Wrapper to execute pkg-config and fill some environment
"       variables
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_pkg_config")
      \ && (g:loaded_pkg_config >= s:k_version)
      \ && !exists('g:force_reload_pkg_config'))
  finish
endif
let g:loaded_pkg_config = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -nargs=+
      \ -complete=customlist,lh#pkgconfig#_complete
      \ PkgConfig
      \ echo lh#pkgconfig#cmd(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
