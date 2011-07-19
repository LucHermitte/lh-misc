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
"       Designed for lh-vim-lib v2.2.1 (v2.2.1 #verbose policy)
" History:      
"       v0.0.1 :Verbose, :Reload, n_K
"       v0.0.2 K keeps the opening bracket if any in order to correctly open
"              function help
"       v0.0.3 :Reload accept arguments (the same as :runtime), and argument
"              completion
"       v0.0.4: Reload works when the &isk contains ' or "
" TODO:         
"       Refactoring feature: move s:functions to autoload plugins
" }}}1
"=============================================================================

let s:k_version = 004
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

command! -b -nargs=* -complete=custom,ReloadComplete Reload  call s:Reload(<f-args>)
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

function! s:ReloadOneScript(crt)
  if a:crt =~ '\<autoload\>'
    " a- For plugins and ftplugins, search for a force_reload variable
    echomsg "Reloading ".a:crt
    exe 'so '.a:crt
  else
    " b- For plugins and ftplugins, search for a force_reload variable
    " NB: the pattern used matches the one automatocally set by mu-template vim
    " templates
    try
      let isk_save = &isk
      set isk-='"
      let re_reload = '\<force_reload\i*'.substitute(fnamemodify(a:crt, ':t:r'), '\(\W\|_\)\+', '_', 'g').'\>'
      let lines = readfile(a:crt)
      let l = match(lines, re_reload)
      " let l = search(re_reload, 'n')
      if l > 0
        " let ll = getline(l)
        let ll = lines[l]
        let reload = matchstr(ll, re_reload)
        let g:{reload} = 1
        echomsg "Reloading ".a:crt." (with ".reload."=1)"
        exe 'so '.a:crt
      else
        throw "Sorry, there is no ".re_reload.' variable to set in order to reload this plugin'
        " todo: find the other pattern like did_ftplugin, etc
      endif
    finally
      let &isk = isk_save
    endtry
  endif
endfunction

function! s:Reload(...)
  if a:0 == 0
    call s:ReloadOneScript(expand('%:p'))
  else
    for file_pat in a:000
      let files = lh#path#glob_as_list(&rtp, file_pat)
      for file in  files
	call s:ReloadOneScript(file)
      endfor
    endfor
  endif
endfunction

let s:commands='^Rel\%[oad]'
function! ReloadComplete(ArgLead, CmdLine, CursorPos)
  let cmd = matchstr(a:CmdLine, s:commands)
  let cmdpat = '^'.cmd

  let tmp = substitute(a:CmdLine, '\s*\S\+', 'Z', 'g')
  let pos = strlen(tmp)
  let lCmdLine = strlen(a:CmdLine)
  let fromLast = strlen(a:ArgLead) + a:CursorPos - lCmdLine 
  " The argument to expand, but cut where the cursor is
  let ArgLead = strpart(a:ArgLead, 0, fromLast )
  return s:FindMatchingFiles(&rtp, ArgLead)
endfunction

" s:FindMatchingFiles(path,ArgLead)                        {{{3
" function from SearchInRuntime
function! s:FindMatchingFiles(pathsList, ArgLead)
  " Convert the paths list to be compatible with globpath()
  let ArgLead = a:ArgLead
  " If there is no '*' in the ArgLead, append it
  if -1 == stridx(ArgLead, '*')
    let ArgLead .=  '*'
  endif
  " Get the matching paths
  let paths = globpath(a:pathsList, ArgLead)

  " Build the result list of matching paths
  let result = ''
  while strlen(paths)
    let p     = matchstr(paths, "[^\n]*")
    let paths = matchstr(paths, "[^\n]*\n\\zs.*")
    let sl = isdirectory(p) ? '/' : '' " use shellslash
    let p     = fnamemodify(p, ':t') . sl
    if strlen(p) && (!strlen(result) || (result !~ '.*'.p.'.*'))
      " Append the matching path is not already in the result list
      let result .=  (strlen(result) ? "\n" : '') . p
    endif
  endwhile

  " Add the leading path as it has been stripped by fnamemodify
  let lead = fnamemodify(ArgLead, ':h') . '/'
  let lead = substitute(lead, '^.[/\\]', '', '') " fnamemodify may returns '.' on windows ...
  if strlen(lead) > 1
    let result = substitute(result, '\(^\|\n\)', '\1'.lead, 'g')
  endif

  " Return the list of paths matching a:ArgLead
  return result
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
