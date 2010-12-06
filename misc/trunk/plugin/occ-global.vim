"=============================================================================
" $Id$
" File:         plugin/occ-global.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.1
" Created:      02nd Jun 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Defines the command :OGlobal/pattern/command that applies a {command}
"       on each occurrence of the {pattern}.
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
let s:k_version = 001
if &cp || (exists("g:loaded_occ_global")
      \ && (g:loaded_occ_global >= s:k_version)
      \ && !exists('g:force_reload_occ_global'))
  finish
endif
let g:loaded_occ_global = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command! -bang -nargs=1 -range OGlobal <line1>,<line2>call s:Global("<bang>", <f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«occ_global».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
function! s:Global(bang, param) range
  let inverse = a:bang == '!'

  " obtain the separator character
  let sep = a:param[0]
  " obtain all fields in the initial command
  let fields = split(a:param, sep)

  " todo: handle inverse
  let l = a:firstline
  while 1
    let l = search(fields[0], 'W')
    if l == -1 || l > a:lastline 
      break 
    endif
    exe fields[1]
  endwhile
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
