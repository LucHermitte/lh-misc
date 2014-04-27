"=============================================================================
" $Id$
" File:         ftplugin/vim/vim_refactor.vim                     {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.2
" Created:      11th May 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       - Move functions to autoload plugin
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/vim
"       Requires Vim7+
"       «install details»
" History:      
" 	v0.0.2
" 	        Some more work done, stil unfinished.
" 	v0.0.1
" 		Move To autoload
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 001
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_vim_refactor")
      \ && (b:loaded_ftplug_vim_refactor >= s:k_version)
      \ && !exists('g:force_reload_ftplug_vim_refactor'))
  finish
endif
let b:loaded_ftplug_vim_refactor = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=* MoveToAutoload call s:MoveToAutoload(<f-args>)

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_vim_refactor")
      \ && (g:loaded_ftplug_vim_refactor >= s:k_version)
      \ && !exists('g:force_reload_ftplug_vim_refactor'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_vim_refactor = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/vim/«vim_refactor».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Move function(s) to autoload {{{3
let s:k_re_function    = '^\s*:\=fu\%[nction]\>'
let s:k_re_endfunction = '^\s*:\=endf\%[unction]\>'
let s:k_re_comment = '^\("[^"]*"\)*"[^"]*$'

" s:BuildDependenciesTree {{{4
function! s:BuildDependenciesTree()
  let deps = []
  let lines = getline(1, '$')

  let N = len(lines)
  " 1- first pass: search the functions
  let i = 0
  while i != N
    let line = lines[i]
    let i += 1

    if line =~ s:k_re_function
      if exists('crt_function') | throw 'Line '.i. ': still in the context of '. (crt_function.name)
      endif
      let crt_function = {'begin':i, 'kind': 'function', 'callers': [], 'callees': []}
      let crt_function.name = matchstr(line, s:k_re_function.'\s*!\=\s\+\zs\S\{-}\ze(')
      call add(deps, crt_function)
      " echo "new function: " . string(crt_function)
    
    elseif line =~ s:k_re_endfunction
      if ! exists('crt_function') 
	throw 'Line '.i. ': outside of any function context' . (!empty(deps) ? ', last function was '.(deps[-1].name) : ', no function started yet')
      endif
      let crt_function.end = i
      " echo "end function: " . string(crt_function)
      unlet crt_function
    endif

  endwhile

  " 2- second pass: locate where the functions are used
  let g:deps = deps
  let re_fns = join(lh#list#transform(deps, [], 'v:1_.name'), '\|')
  let re_fns = substitute(re_fns, 's:', '\\%(s:\\|<[sS][iI][dD]>\\)', 'g')
  let re_fns = '\%('.re_fns.'\)\ze\s*('

  let callers = []

  let i = 0
  while i != N
    silent! unlet caller
    let i = lh#list#match(lines, re_fns, i)
    if i == -1 | break | endif


    " Find kind of the caller
    " - if multiline call, find the first line
    let j = i
    while lines[j] =~ '^\s*\\'
      let j -= 1
    endwhile

    let line0 = lines[j]
    let line = lines[i]

    " now i is no more the index in the lines list, but a line number
    " (and also iterated for the next element in the list)
    let i += 1 | let j += 1
    let c = lh#list#find_if(callers, 'v:1_.line =='.i )
    if c == -1
      " echo "new caller: ".i
      let caller = { 'line': i, 'callees': [] }
    else
      " echo "caller reused: ".i
    endif


    " todo: support ":set statusline=foo\ {Function()}"
    " todo: extract the name
    if line0 =~ '^\s*[anviosx]\%(nore\)\=map'
      " echo i." mapping definition"
      let caller.kind = 'map'
    elseif line0 =~ '^\s*[anviosx]\%(nore\)\=ab\%[br]'
      " echo i." abbr definition"
      let caller.kind = 'abbr'
    elseif line0 =~ '^\s*[anviosx]\%(nore\)\=me\%[nu]'
      " echo i." menu definition"
      let caller.kind = 'menu'
    elseif line0 =~ '^\s*com\%[mmand]'
      " echo i." command definition"
      let caller.kind = 'command'
    elseif line0 =~ s:k_re_function
      " Definition => ignore
      " echo i." function definition"
      continue
    elseif line0 =~ s:k_re_comment
      " Comment => ignore
      " echo i." function comment: " . line0
      " May need to update function definition range...
      continue
    else " within a function
      for fn in deps
	if fn.begin < i && i < fn.end 
          " echo i." within a function --> " . string(fn)
	  let caller = fn
	  break 
	endif
      endfor
      if ! has_key(caller, 'kind')
	let caller.kind = 'script' " find a better name
        " echo i." ouside any function> "
      endif
    endif

    " loop to find which functions were called 
    let p = 0
    while 1
      let p = match(line, re_fns, p) " I don't see any function that gives begin+end at once ...
      if -1 == p | break | endif
      let m = matchstr(line, re_fns, p)
      " if empty(m) | break | endif
      let m = substitute(m, '\c<sid>', 's:', 'g')

      let i_callee = lh#list#find_if(deps, 'v:1_.name == '.string(m))
      " Assert
      if i_callee == -1 | throw "Line ".i.": cannot found reference for function ".m | endif
      call add(deps[i_callee].callers, j)
      call add(caller.callees, m)

      let p += len(m)
    endwhile


    " Remember callers that are not functions (as they are stored elsewhere)
    if caller.kind != 'function'
      call add(callers, caller)
    endif

  endwhile


  " 99- return the dependencies found
  call extend(deps, callers)
  return deps
endfunction

" Function: s:Name(function) {{{4
function! s:Name(function)
  let name = a:function.kind == 'function'
        \ ? (a:function.name)
        \ : (a:function.kind) . (a:function.line)
  return name
endfunction

" Function: s:GetCalleeInfo(callee_name, deps) {{{3
function! s:GetCalleeInfo(callee_name, deps)
  let callee = filter(copy(a:deps), 'has_key(v:val, "name") && v:val["name"] == '.string(a:callee_name))
  return callee
endfunction

" Function: s:DisplayCalleesOf(deps, function, indent) {{{4
function! s:DisplayCalleesOf(deps, function, indent)
  let name = s:Name(a:function)
  echo repeat(' ', a:indent*&sw) . '+ '. name
  for fn in a:function.callees
    if name == fn
      " Special case for recurvise functions
      echo repeat(' ', (a:indent+1)*&sw) . '+ '. fn . '...'
    else
      let fn_data = s:GetCalleeInfo(a:deps, fn)
      " if empty => error
      call s:DisplayCalleesOf(a:deps, fn_data[0], a:indent+1)
    endif
  endfor
endfunction

" Function: s:IsCalledFrom(fn_data, line) {{{4
function! s:IsCalledFrom(fn_data, line)
  let res = (has_key(a:fn_data, 'line') && a:fn_data.line == a:line)
        \ || ( has_key(a:fn_data, 'begin') && a:fn_data.begin <= a:line && a:line <= a:fn_data.end)
  " echo "check: if " . a:line . " is within ". string(a:fn_data) . " -> " . res
  return res
endfunction

" Function: s:DisplayCallersOf(deps, function, indent) {{{4
function! s:DisplayCallersOf(deps, function, indent)
  let name = s:Name(a:function)
  echo repeat(' ', a:indent*&sw) . '+ '. name
  if !has_key(a:function, 'callers') | return | endif
  for line in a:function.callers
    let fn_data = filter(copy(a:deps), 's:IsCalledFrom(v:val,'. line.')')
    if !empty(fn_data)
      if s:Name(fn_data[0]) == name
        " Special case for recurvise functions
        echo repeat(' ', (a:indent+1)*&sw) . '+ '. name . '...'
      else
        call s:DisplayCallersOf(a:deps, fn_data[0], a:indent+1)
      endif
    endif
  endfor
endfunction

" Functions: s:DisplayDependenciesTree {{{4
function! s:DisplayDependenciesTree(deps)
  " 1- callers -> callees
  echo "####callers -> callees####"
  for fct in a:deps
    call s:DisplayCalleesOf(a:deps, fct, 0)
  endfor

  " 2- callees -> callers
  echo "####callees -> callers####"
  for fct in a:deps
    call s:DisplayCallersOf(a:deps, fct, 0)
  endfor
endfunction

" Function: s:TagExposedFunctions(deps) {{{3
function! s:TagExposedFunctions(deps, prefix)
  for caller in filter(copy(a:deps), 'v:val.kind =~ "map\\|abbr\\|menu\\|command\\|script"')
    for callee_name in caller.callees
      let callee = s:GetCalleeInfo(callee_name, a:deps)[0]
      " if empty => error
      " echo string(callee)
      if !has_key(callee, 'name')
        echo "ignoring ".s:Name(callee)
      else
        if !has_key(callee, 'new_name')
          let callee.new_name = a:prefix.'#'.lh#dev#naming#to_underscore(substitute(callee.name, '^s:', '_', ''))
          echo callee.name . ' -> ' . callee.new_name
        endif
      endif
    endfor
  endfor
endfunction

" s:MoveToAutoload {{{4
function! s:MoveToAutoload(...)
  " For each function, there is a choice:
  " - left where it is defined (then the function must not be referenced in the
  "   functions moved) -- a check may not work in case of cyclic calls between
  "   functions ...
  " - moved, but the name is left as it is
  " - moved, but exported by autoload plugin -- according to the naming policy
  " When a function is moved, it may induce the move of other functions
  "
  " 0- Build a dependency tree between functions (and mappings, abbreviation,
  " commands, autocommands)
  " Dependencies may be missed in case of a "exe 'map'...", or other commands
  " like "IAbbr"
  let deps = s:BuildDependenciesTree()
  call lh#common#echomsg_multilines(join(deps, "\n"))

  " call s:DisplayDependenciesTree(deps)

  " 0.2- determine the name of the autoload plugin, and of the prefix
  let fname = a:0 > 0 ? (a:1) : ''
  if empty(fname)
    let fname = expand('%:p')
    let ft = matchstr(fname, 'ftplugin/\zs[^/.]*')
    let fname = substitute(fname, 'ftplugin/.*\<'.ft.'\(\>\|_\)\ze.*\.vim', 'autoload/lh/'.ft.'/', '')
  else
    if fname !~ 'autoload'
      let fname = 'autoload/'.fname
    endif
  endif
  let prefix = substitute(fname, '.*/autoload/\(.*\)\.vim$', '\1', '')
  let prefix = substitute(prefix, '/', '#', 'g')
  echomsg "go into ".fname . "  (".prefix.")"

  " 0.3- determine the new name of the main function moved
  let new_fn_name = a:0 > 1 . (a:2) : ''


  " 1- determine the functions to move
  " 1.1- shall be able to work on a selected range, a function name, or all
  " functions from a script (plugin, ftplugin)
  " Let's say that default = every function from the script
  " 1.2- determine the exposed functions to move, and their new name
  " Check maps, commands, script variables, abbrs, and menus for functions that
  " need to be exposed.
  call s:TagExposedFunctions(deps, prefix)
  " 1.3- determine the dependant functions (just in case ?)
  "
  " 2- where they are used: change their reference name
  " 2.5- check everything is consistant: i.e. a function moved, but that stays
  " internal shall not be referenced anymore.
  " 2.?- what about comments ?
  "
  " 3- move the funtions
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
