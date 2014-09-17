"=============================================================================
" $Id$
" File:         plugin/vim_maintain.vim{{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.5
" Created:      16th Sep 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Commands and mapping to help maintaining VimL scripts
"       Designed for lh-vim-lib v2.2.1 (v2.2.1 #verbose policy)
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/plugin
"       Requires Vim7+
" History:      
"       v0.0.5: Reload and Verbose moved from ftplugin
" TODO:         «missing features»
" }}}1
"=============================================================================

" ## Avoid global reinclusion          {{{1
let s:k_version = 005
if &cp || (exists("g:loaded_vim_maintain")
      \ && (g:loaded_vim_maintain >= s:k_version)
      \ && !exists('g:force_reload_vim_maintain'))
  finish
endif
let g:loaded_vim_maintain = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" ## Commands and Mappings             {{{1
command! -nargs=* -complete=custom,ReloadComplete Reload  call s:Reload(<f-args>)
command! -nargs=? Verbose call s:Verbose(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" ## Functions                         {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«vim_maintain».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
"
" # Reloading          {{{2
" Function: s:ReloadOneScript(crt)                      {{{3
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

" Function: s:Reload(...)                               {{{3
function! s:Reload(...)
  try 
    let s_isk = &isk
    set isk&vim
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
  finally
    let &isk = s_isk
  endtry
endfunction

" Function: ReloadComplete(ArgLead, CmdLine, CursorPos) {{{3
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

" Function: s:FindMatchingFiles(path,ArgLead)           {{{3
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

" # Verbose functions  {{{2
" Function: s:Verbose(...)                              {{{3
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

" Function: s:CurrentScript()                           {{{3
function! s:CurrentScript()
  let crt = expand('%:p')
  let crt = lh#path#strip_start(crt, &rtp)
  return crt
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
