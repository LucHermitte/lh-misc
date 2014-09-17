"=============================================================================
" $Id$
" File:         ftplugin/vim/vim_maintain.vim                     {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.4
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
" History:      
"       v0.0.1 :Verbose, :Reload, n_K
"       v0.0.2 K keeps the opening bracket if any in order to correctly open
"              function help
"       v0.0.3 :Reload accept arguments (the same as :runtime), and argument
"              completion
"       v0.0.4: Reload works when the &isk contains ' or "
"       v0.0.5: Reload and Verbose moved to plugin
" TODO:         
"       Refactoring feature: move s:functions to autoload plugins
" }}}1
"=============================================================================

let s:k_version = 005
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

" Function: s:CurrentHelpWord() {{{3
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
