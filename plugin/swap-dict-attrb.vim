"=============================================================================
" File:         plugin/swap-dict-attrb.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      24th Aug 2021
" Last Update:  24th Aug 2021
"------------------------------------------------------------------------
" Description:
"       Add two commands to switch between `['foobar']` and `.foobar`
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim

if &cp || (exists("g:loaded_swap_dict_attrb")
      \ && (g:loaded_swap_dict_attrb >= s:k_version)
      \ && !exists('g:force_reload_swap_dict_attrb'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_swap_dict_attrb = s:k_version
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -range=1
      \ ToAttribute <line1>,<line2>s/\v\[(["'])([^"']+)\1]/.\2/gc
command! -range=1 -nargs=? -complete=customlist,s:compl_to_dict
      \ ToDict      call s:to_dict(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«swap_dict_attrb».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.

function! s:to_dict(...) range abort
  let quote = get(a:, 1, "'")
  exe printf('%s,%ss/\v\.(\k+)/[%s\1%s]/gc', a:firstline, a:lastline, quote, quote)
endfunction

function! s:compl_to_dict(...) abort
  return ['"', "'"]
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
