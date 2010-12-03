"=============================================================================
" $Id$
" File:         ftplugin/vim/vim_maintain.vim                     {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.2
" Created:      07th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Commands and mapping to help maintaining VimL scripts
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/vim
"       Requires Vim7+
"       Designed for lh-vim-lib v2.2.1 (v2.2.1 #verbose policy)
" History:      
"       v0.0.1 :Verbose, :Reload, n_K
"       v0.0.2 K keeps the opening bracket if any in order to correctly open
"              function help
" TODO:         
"       Refactoring feature: move s:functions to autoload plugins
" }}}1
"=============================================================================

let s:k_version = 002
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_vim_maintain")
      \ && (b:loaded_ftplug_vim_maintain >= s:k_version)
      \ && !exists('g:force_reload_ftplug_vim_maintain'))
  finish
endif
let b:loaded_ftplug_vim_maintain = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <buffer> K :help <c-r>=<sid>CurrentHelpWord()<cr><cr>
vnoremap <buffer> K <c-\><c-n>:help <c-r>=lh#visual#selection()<cr><cr>

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=0 Reload  call s:Reload()
command! -b -nargs=? Verbose call s:Verbose(<f-args>)

" move function to autoload plugin

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_vim_maintain")
      \ && (g:loaded_ftplug_vim_maintain >= s:k_version)
      \ && !exists('g:force_reload_ftplug_vim_maintain'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_vim_maintain = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/vim/«vim_maintain».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

function! s:Reload()
  let crt = expand('%:p')
  if crt =~ '\<autoload\>'
    " a- For plugins and ftplugins, search for a force_reload variable
    exe 'so '.crt
  else
    " b- For plugins and ftplugins, search for a force_reload variable
    " NB: the pattern used matches the one automatocally set by mu-template vim
    " templates
    let re_reload = '\<force_reload\i*'.substitute(expand('%:t:r'), '\(\W\|_\)\+', '_', 'g').'\>'
    let l = search(re_reload, 'n')
    if l > 0
      let ll = getline(l)
      let reload = matchstr(ll, re_reload)
      let g:{reload} = 1
      exe 'so '.crt
    else
      throw "Sorry, there is no ".re_reload.' variable to set in order to reload this plugin'
      " todo: find the other pattern like did_ftplugin, etc
    endif
  endif
endfunction

function! s:Verbose(...)
  " This feature expects autoload/foo/bar.vim to have a
  " "foo#bar#verbose(...) : int" function that may change the local verbososity
  " of the autoload plugin, and that always return that local verbosity.
  " NB: mu-template autoload-plugin template-file automatically defines this
  " function
  let crt = s:CurrentScript()
  if crt !~ '^autoload'
    throw "Sorry, this command is dedicated at setting the verbose level of autoload plugins only"
  endif
  let scope = matchstr(crt, '^autoload.\zs.*\ze\.vim$')
  let scope = substitute(scope, '[/\\]', '#', 'g')
  let verbose_cmd = scope.'#'.'verbose'
  if !exists('*'.verbose_cmd)
    exe 'source '.expand('%:p')
    if !exists('*'.verbose_cmd)
      throw "Sorry, this autoload plugin does not provide a ".verbose_cmd." function."
    endif
  endif
  if a:0 == 0
    echo scope . ' verbosity is '.{verbose_cmd}()
  else
    call {verbose_cmd}(a:1)
  endif
endfunction

function! s:CurrentScript()
  let crt = expand('%:p')
  let crt = lh#path#strip_start(crt, &rtp)
  return crt
endfunction

function! s:CurrentHelpWord()
  try 
    let isk = &isk
    set isk+=(,:,#,&
    let w = expand('<cword>')
  finally
    let &isk = isk
  endtry
  let w = matchstr(w, '^[:&]\=\k\+(\=')
  if w[-1:] == '('
    let w .= ')'
  elseif w[0] == '&'
    let w = "'".w[1:]."'"
  endif
  return w
endfunction
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
