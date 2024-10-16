"=============================================================================
" File:         ftplugin/python_adaptative_tw.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      16th Oct 2024
" Last Update:  16th Oct 2024
"------------------------------------------------------------------------
" Description:
"       Adapt &tw to comments and docstring
"
"------------------------------------------------------------------------
" History:
" v0.0.1: First version
"         (*) Works w/ `Q` only, compatible vim & nvim
"         (*) Automatically updated tw is too slow
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim

if &cp || (exists("b:loaded_ftplug_python_adaptative_tw")
      \ && (b:loaded_ftplug_python_adaptative_tw >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_adaptative_tw'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_python_adaptative_tw = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" ### Local settings {{{2

" Don't wrap normal code, only comments
setlocal fo-=t

" ### Local mappings {{{2

" # Attempt 1
xnoremap <buffer> <silent> Q :call <sid>reformat_visual()<cr>
nnoremap <buffer> <silent> <expr> Q <sid>reformat_normal()


" ### Options {{{2
" Default values             {{{4
LetIfUndef g:style.textwidth.comment   = 79
LetIfUndef g:style.textwidth.docstring = 79
" LetIfUndef g:style.textwidth.default   = &tw

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_python_adaptative_tw")
      \ && (g:loaded_ftplug_python_adaptative_tw >= s:k_version)
      \ && !exists('g:force_reload_ftplug_python_adaptative_tw'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_python_adaptative_tw = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" ### Helper functions {{{2
" s:getSNR([func_name])       {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

" Function: s:synID(l, c)     {{{3
function! s:synID(l, c) abort
  return synIDattr(synID(a:l, a:c, 0), "name")
endfunction

" Function: s:compute_tw(ft)  {{{3
function! s:compute_tw(ft) abort
  let lin = line('.')

  let syn = s:synID(lin, col('.'))
  if syn =~? 'comment'
    return lh#ft#option#get('style.textwidth.comment', a:ft, &tw)
  elseif a:ft == 'python' && syn =~? '\vstring|^$' " Special case for docstrings
    while lin >= 1
      let line = getline(lin)
      if line =~ '\v^\s*$' | let lin -= 1 | continue | endif
      if s:synID(lin, col([lin, "$"])-1) !~? '\vString|pythonTripleQuotes'
        break
      endif
      if match(line, "\\('''\\|\"\"\"\\)") > -1
        " Assume that any longstring is a docstring
        return lh#dev#option#get('style.textwidth.docstring', a:ft, &tw)
      endif
      let lin -= 1
    endwhile
  endif
  return lh#dev#option#get('style.textwidth.default', a:ft, &tw)
endfunction

" ### Attempts {{{2

" ## Attempt 1: map based: specialize Q {{{3
function! s:do_clean() abort
  " echomsg "restore tw"
  call s:cleanup.finalize()
endfunction

function! s:reformat_visual() abort
  let s:cleanup = lh#on#exit()
        \.restore('&tw')
  try
    let tw = s:compute_tw(&ft)
    " echomsg 'setlocal tw='.tw
    exe 'setlocal tw='.tw
    normal! gvgq
  finally
    call s:cleanup.finalize()
  endtry
endfunction

function! s:reformat_normal() abort
  let s:cleanup = lh#on#exit()
        \.restore('&tw')
    let tw = s:compute_tw(&ft)
    exe 'setlocal tw='.tw
    " echomsg 'setlocal tw='.tw
    call lh#event#register_for_one_execution_at('SafeState', 'call '.s:getSNR('do_clean').'()', 'RestoreTW1')
    return 'gq'
endfunction

" ## Attempt 2: Update tw on syntax change when the cursor is moved {{{3
" Inspiration: https://stackoverflow.com/a/4028423/15934
" See Also:
"       The more generic https://github.com/inkarkat/vim-OnSyntaxChange
"       and https://fjcasas.es/posts/smart-textwidth-on-vim-when-writing-comments
"       But I need to detect docstrings as well...
" Problem:
"       Checking synID() everytime the cursor is moved is much too slow!
" Todo:
"       Rewrite it in vimscript 2
" => disable for now
finish

function! s:update_tw(ft) abort
  call setbufvar('%', '&tw', s:compute_tw(a:ft))
endfunction

" # autocommand registration {{{4
augroup WatchSyntax
  au!
  autocmd! CursorMoved,CursorMovedI,BufEnter <buffer> call s:update_tw(&ft)
augroup END

" }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}1
"=============================================================================
" vim600: set fdm=marker:
