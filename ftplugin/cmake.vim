"=============================================================================
" $Id$
" File:         ftplugin/cmake.vim                                {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      002
" Created:      01st Mar 2012
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Configures matchit.vim for CMake
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin
" }}}1
"=============================================================================

let s:k_version = 2
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cmake")
      \ && (b:loaded_ftplug_cmake >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cmake'))
  finish
endif
let b:loaded_ftplug_cmake = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local options {{{2
" Let the matchit plugin know what items can be matched.
if exists("loaded_matchit")
  let b:match_ignorecase = 1
  let b:match_words =
        \ '\<if\>:\<elseif\>:\<else\>:\<endif\>,' .
        \ '(:)'
  " Ignore ":syntax region" commands, the 'end' argument clobbers if-endif
  let b:match_skip = 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||
        \ synIDattr(synID(line("."),col("."),1),"name") =~? "comment\\|string"'
endif

setlocal tw=100

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cmake")
      \ && (g:loaded_ftplug_cmake >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cmake'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cmake = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cmake/«cmake».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
