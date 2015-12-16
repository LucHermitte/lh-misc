"=============================================================================
" File:         ftplugin/gitcommit.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      16th Dec 2015
" Last Update:  16th Dec 2015
"------------------------------------------------------------------------
" Description:
"       «description»
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

runtime! ftplugin/markdown*.vim ftplugin/markdown/*.vim

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_gitcommit")
      \ && (b:loaded_ftplug_gitcommit >= s:k_version)
      \ && !exists('g:force_reload_ftplug_gitcommit'))
  finish
endif
let b:loaded_ftplug_gitcommit = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2


"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_gitcommit")
      \ && (g:loaded_ftplug_gitcommit >= s:k_version)
      \ && !exists('g:force_reload_ftplug_gitcommit'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_gitcommit = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/gitcommit/«gitcommit».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
