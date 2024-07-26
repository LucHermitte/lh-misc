"=============================================================================
" File:         ftplugin/python_set.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.2.
let s:k_version = 002
" Created:      08th Feb 2024
" Last Update:  26th Jul 2024
"------------------------------------------------------------------------
" Description:
"       My settings for Python
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim

if &cp || (exists("b:loaded_ftplug_python_set")
      \ && (b:loaded_ftplug_python_set >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_set'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_python_set = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

" `;` will act as the close-everything-that-follows trigger. And if there is
" not brackets to close, it will get inserted
:inoremap <buffer> ; <C-R>=lh#brackets#close_all_and_jump_to_last_on_line(lh#brackets#closing_chars(), {'insert_otherwise': ';'})<CR>

"------------------------------------------------------------------------
" Local commands {{{2
"
" MakeWith is defined in BuildToolsWrappers
if exists(':MakeWith')
  " In the 3 following commands:
  " - Any options in --whatever will override default options
  " - otherwise, it will override the default path where it would have been
  "   executed.
  command! -buffer -nargs=*
        \ -complete=dir
        \ Pylint
        \ :call s:check_with('pylint', <f-args>)

  command! -buffer -nargs=*
        \ -complete=dir
        \ Mypy
        \ :call s:check_with('mypy', <f-args>)

  command! -buffer -nargs=*
        \ -complete=dir
        \ RuffCheck
        \ :call s:check_with('ruff check', <f-args>)
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_python_set")
      \ && (g:loaded_ftplug_python_set >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_set'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_python_set = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/python/«python_set».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

let s:k_tools_default_options = {
      \ 'pylint': ['--disable=fixme']
      \ }

function! s:check_with(tool, ...) abort
  let options = []
  let where   = lh#option#get('paths.sources')
  for o in a:000
    if o[0] == '-'
      call add(options, o)
    else
      let where = o
    endif
  endfor
  if empty(options)
    let options = lh#option#get(a:tool.'.options', get(s:k_tools_default_options, a:tool, []))
  endif
  let cmd = [ ':MakeWith', a:tool] + options + [where]
  exe join(cmd, ' ')
endfunction
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}1
"=============================================================================
" vim600: set fdm=marker:
