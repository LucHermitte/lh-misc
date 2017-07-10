"=============================================================================
" File:         ftplugin/markdown_githubtoc.vim                   {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.2
let s:k_version = 002
" Created:      24th Nov 2015
" Last Update:  10th Jul 2017
"------------------------------------------------------------------------
" Description:
"       Generate TOC for a github markdown file
"
" Run for instance:
"   :1,$Toc
" where you want the TOC inserted
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_markdown_githubtoc")
      \ && (b:loaded_ftplug_markdown_githubtoc >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_githubtoc'))
  finish
endif
let b:loaded_ftplug_markdown_githubtoc = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=0 -range=% Toc <line1>,<line2>call lh#markdown#toc#_generate()

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_markdown_githubtoc")
      \ && (g:loaded_ftplug_markdown_githubtoc >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_githubtoc'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_markdown_githubtoc = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/markdown/«markdown_githubtoc».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
