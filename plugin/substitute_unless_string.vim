"=============================================================================
" File:         plugin/substitute_unless_string.vim               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      22nd Apr 2015
" Last Update:  22nd Apr 2015
"------------------------------------------------------------------------
" Description:
"       Answer to http://vi.stackexchange.com/questions/3028
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_substitute_unless_string")
      \ && (g:loaded_substitute_unless_string >= s:k_version)
      \ && !exists('g:force_reload_substitute_unless_string'))
  finish
endif
let g:loaded_substitute_unless_string = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
:command! -bang -nargs=1 -range SubstituteUnlesString <line1>,<line2>call s:SubstituteUnlessString("<bang>", <f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«substitute_unless_string».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.

" Function: s:SubstituteUnlessString(bang, repl_arg) {{{3
function! s:SubstituteUnlessString(bang, repl_arg) range abort
  let do_loop = a:bang != "!"
  let sep = a:repl_arg[0]
  let fields = split(a:repl_arg, sep)
  let cleansed_fields = map(copy(fields), 'substitute(v:val, "\\\\[<>]", "", "g")')
  " build the action to execute
  if fields[1] =~ '^\\='
    let replacement = matchstr(fields[1], '^\\=\zs.*')
  elseif fields[1] =~ '&\|\\\d'
    let replacement = "'".substitute(fields[1], '&\|\\\(\d\)', '\=string(".submatch(".(submatch(0)=="&"?"0":submatch(1)).").")', 'g') ."'"
  else
    let replacement = string(fields[1])
  endif
  let action = '\=(match(map(synstack(line("."), col(".")), "synIDattr(v:val, \"name\")"), "\\cstring")==-1 ? '.replacement.' : submatch(0))'
  let cmd = a:firstline . ',' . a:lastline . 's'
	\. sep . fields[0]
	\. sep . action
        \. sep.(len(fields)>=3 ? fields[2] : '')
  " echomsg cmd
  exe cmd
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
