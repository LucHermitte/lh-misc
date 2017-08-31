"=============================================================================
" File:		.vim/_vimrc_local.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-misc/>
" Version:	2.0.0
" Created:	22nd Apr 2010
" Last Update:	14th Apr 2017
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

let s:k_version = 190
" Always loaded {{{1
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded__vim_vimrc_local")
      \ && (b:loaded__vim_vimrc_local >= s:k_version)
      \ && !exists('g:force_reload__vim_vimrc_local'))
  finish
endif
let b:loaded__vim_vimrc_local = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local options {{{2
let s:script_dir = expand('<sfile>:p:h')
let s:script     = expand('<sfile>:p')

silent! unlet b:crt_project
if expand('%:p:h') !~ 'tests/lh'
  " Project --define Vim\ Scripts
  if lh#option#is_unset(lh#project#define(s:, { 'name': 'Vim Scripts', 'auto_discover_root':0 }))
    finish
  endif
  call lh#let#to('p:tags_dirname', s:script_dir)
  " Be sure tags are automatically updated on the current file
  LetIfUndef p:tags_options.no_auto 0
  " Declare the indexed filetypes
  call lh#tags#add_indexed_ft('vim')
  LetTo p:tags_options.flags ' --exclude="flavors/*" --exclude="bundle/*" --exclude="lh-template" --exclude="lh-UT" --exclude="vim-UT" --exclude="lh-BTW"'

  " Project --define subproject_{name}
  let name = lh#path#strip_start(expand('%:p'), [lh#path#vimfiles().'/.addons', lh#path#vimfiles()])
  let name = substitute(name, '\v^.{-}[/\\](.{-})[/\\].*', '\1', '')
  let name = substitute(name, '[^A-Za-z0-9_]', '_', 'g')
  let opt = {'name': name}
  if expand('%:p') == expand('<sfile>:p')
    " This _vimrc_local.vim file!
    let opt.auto_discover_root = {'value': expand('%:p:h')}
  endif

  " Update Vim &tags option w/ the tag file produced for the current project
  call lh#tags#update_tagfiles() " uses p:tags_dirname

  if lh#option#is_unset(lh#project#define(s:, opt, 'subproject_'.name))
    finish
  endif
else
  Project --define Vim\ Tests
  " call lh#project#define(s:, {'name': 'Vim Tests'}, 'prj_tests')
  LetTo p:tags_dirname = expand('%:p:h')
  LetIfUndef p:tags_options.flags ' --exclude="*.vim"'
  LetTo p:vim_maintain.remove_trailing = 0

  " Update Vim &tags option w/ the tag file produced for the current project
  call lh#tags#update_tagfiles() " uses p:tags_dirname
endif

" TODO: only compute this once -> for parent project
if lh#has#patch('patch-7.3.465')
  let s:tags = glob( $HOME. '/.vim/**/tags', 1, 1)
else
  let s:tags = split(glob( $HOME. '/.vim/**/tags'), "\n")
endif
" Filter out non VAM managed plugins, doc, tests
call filter(s:tags, 'v:val !~ "\\v\\.vim[/\\\\](flavors|bundle|(.*[/\\\\])=(doc|tests))>"')

call lh#option#add('l:tags', s:tags)

"=============================================================================
" }}}1
"=============================================================================
" vim600: set fdm=marker:
