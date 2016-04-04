"=============================================================================
" File:           ftplugin/tex/tex-fold.vim                         {{{1
" Initial Author: Johannes Zellner <johannes@zellner.org>
" URL:            http://www.zellner.org/vim/fold/tex.vim
" Maintainer:     Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"                 <URL:http://github.com/LucHermitte/lh-misc>
" Version:        0.0.1.
let s:k_version = 001
" Created:      04th Apr 2016
" Last Update:  04th Apr 2016
"------------------------------------------------------------------------
" Description:
"       Folding for (La)TeX
" }}}1
"=============================================================================

" Avoid local reinclusion {{{1
if &cp || (exists("b:loaded_ftplug_tex_fold")
      \ && (b:loaded_ftplug_tex_fold >= s:k_version)
      \ && !exists('g:force_reload_ftplug_tex_fold'))
  finish
endif
let b:loaded_ftplug_tex_fold = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}1

"------------------------------------------------------------------------
" Settings {{{1

" Settings                                       {{{2
setlocal foldexpr=lh#tex#fold#expr(v:lnum)
setlocal foldmethod=expr
setlocal foldtext=lh#tex#fold#text()

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
