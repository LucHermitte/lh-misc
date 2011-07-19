"=============================================================================
" $Id$
" File:		.vim/_vimrc_local.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.0.0
" Created:	22nd Apr 2010
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
"   My local vimrc for vim script edition
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:k_version = 100
" Always loaded {{{1
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded__vim_vimrc_local")
      \ && (b:loaded__vim_vimrc_local > s:k_version)
      \ && !exists('g:force_reload__vim_vimrc_local'))
  finish
endif
let b:loaded__vim_vimrc_local = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local options {{{2

if expand('%:p:h') !~ 'tests/lh'
  let b:tags_dirname = expand('<sfile>:p:h')
  let b:tags_options = ' --exclude=tests --exclude="*.cpp" --exclude="*.h" --exclude="*.template" --exclude=cpo_save'
else
  let b:tags_dirname = expand('%:p:h')
  let b:tags_options = ' --exclude="*.vim"'
endif

call lh#option#add('l:tags', b:tags_dirname . '/tags')


"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded__vim_vimrc_local")
      \ && (g:loaded__vim_vimrc_local > s:k_version)
      \ && !exists('g:force_reload__vim_vimrc_local'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded__vim_vimrc_local = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Functions }}}2
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
