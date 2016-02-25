"=============================================================================
" File:         plugin/PrependNumbers.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      29th Apr 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       «description»
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_PrependNumbers")
      \ && (g:loaded_PrependNumbers >= s:k_version)
      \ && !exists('g:force_reload_PrependNumbers'))
  finish
endif
let g:loaded_PrependNumbers = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
command!  -range=% -nargs=? PrependNumbers <line1>,<line2>call s:Prepend(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«PrependNumbers».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
function! s:ReplExpr(nb_digits, number)
  return repeat('0', a:nb_digits - strlen(a:number)).a:number
endfunction

function! s:Prepend(...) range
  let pattern = a:0 > 0 ? '\ze'. a:1 : '^'
  let nb_values = (a:lastline - a:firstline) + 1
  let nb_digits = strlen(nb_values)
  exe ':'.a:firstline.','a:lastline.'s#'.pattern.'#\=s:ReplExpr(nb_digits, 1+ line(".")-'.a:firstline.')." "#'
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
