"=============================================================================
" File:		.vim/_vimrc_local.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	22nd Apr 2010
" Last Update:	08th Sep 2016
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

let s:k_version = 131
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
  " Be sure tags are automatically updated on the current file
  LetIfUndef b:tags_options.no_auto 0
  " Declare the indexed filetypes
  call lh#tags#add_indexed_ft('vim')
else
  let b:tags_dirname = expand('%:p:h')
  LetIfUndef b:tags_options.flags ' --exclude="*.vim"'
endif
" Update Vim &tags option w/ the tag file produced for the current project
call lh#tags#update_tagfiles() " uses b:tags_dirname

try
  let s:tags = glob( $HOME. '/.vim/**/tags', 1, 1)
catch /.*/
  let s:tags = split(glob( $HOME. '/.vim/**/tags'), "\n")
endtry
call filter(s:tags, 'v:val !~ "\\v\\.vim[/\\\\](flavors|bundle)>"')

call lh#option#add('l:tags', s:tags)


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
