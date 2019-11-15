"=============================================================================
" File:		.vim/_vimrc_local.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-misc/>
" Version:	2.0.0
" Created:	22nd Apr 2010
" Last Update:	15th Nov 2019
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

let s:k_version = 200
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

Unlet b:crt_project
if expand('%:p:h') !~ 'tests/lh'
  " Project --define Vim\ Scripts
  if lh#option#is_unset(lh#project#define(s:, { 'name': 'Vim Scripts', 'auto_discover_root':0 }))
    finish
  endif
  call lh#let#to('p:paths.tags.src_dir', s:script_dir)
  " Be sure tags are automatically updated on the current file
  LetIfUndef p:tags_options.no_auto 0
  " Declare the indexed filetypes
  call lh#tags#add_indexed_ft('vim')
  " LetTo p:tags_options.flags ' --exclude="flavors/*" --exclude="bundle/*" --exclude="lh-template" --exclude="lh-UT" --exclude="vim-UT" --exclude="lh-BTW"'
  let s:excludes = lh#let#to('p:tags_options.excludes', [])
  let s:excludes += ['"flavors/*"', '"bundle/*"', 'lh-template', 'lh-UT', 'vim-UT', 'lh-BTW']

  " Project --define subproject_{name}
  let s:name = lh#path#strip_start(expand('%:p'), [lh#path#vimfiles().'/.addons', lh#path#vimfiles()])
  let s:name = substitute(s:name, '\v^.{-}[/\\](.{-})[/\\].*', '\1', '')
  let s:name = substitute(s:name, '[^A-Za-z0-9_]', '_', 'g')
  let s:opt = {'name': s:name}
  if expand('%:p') == expand('<sfile>:p')
    " This _vimrc_local.vim file!
    let s:opt.auto_discover_root = {'value': expand('%:p:h')}
  endif

  " Update Vim &tags option w/ the tag file produced for the current project
  call lh#tags#update_tagfiles() " uses p:tags_dirname

  if lh#option#is_unset(lh#project#define(s:, s:opt, 'subproject_'.s:name))
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

" Note: As I have only one tags file now at ~/.vim/ root directory, I
" don't need to look for other tag files.
if 0
  " Only compute this once -> for parent project
  " or when we force reloading the local vimrc
  if !exists('s:tags') || get(g:, 'force_reload__vim_vimrc_local', 0)
    if lh#has#patch('patch-7.3.465')
      let s:tags = glob( $HOME. '/.vim/addons/**/tags', 1, 1)
    else
      let s:tags = split(glob( $HOME. '/.vim/addons/**/tags'), "\n")
    endif
    " Filter out non VAM managed plugins, doc, tests
    call filter(s:tags, 'v:val !~ "\\v\\.vim[/\\\\](flavors|bundle|(.*[/\\\\])=(doc|tests))>"')

    call lh#option#add('l:tags', s:tags)
  endif
endif

"=============================================================================
" }}}1
"=============================================================================
" vim600: set fdm=marker:
