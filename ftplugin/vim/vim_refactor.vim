"=============================================================================
" File:         ftplugin/vim/vim_refactor.vim                     {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.2
" Created:      11th May 2010
" Last Update:  25th May 2018
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
"       v0.0.3
"               Some more work done, stil unfinished.
"       v0.0.2
"               Some more work done, stil unfinished.
"       v0.0.1
"               Move To autoload
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 003
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
function! s:BuildDependenciesTree() abort
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
      let crt_function = {'range': {'begin':i}, 'kind': 'function', 'callers': [], 'callees': []}
      let crt_function.name = matchstr(line, s:k_re_function.'\s*!\=\s\+\zs\S\{-}\ze(')
      call add(deps, crt_function)
      " echo "new function: " . string(crt_function)

    elseif line =~ s:k_re_endfunction
      if ! exists('crt_function')
        throw 'Line '.i. ': outside of any function context' . (!empty(deps) ? ', last function was '.(deps[-1].name) : ', no function started yet')
      endif
      let crt_function.range.end = i
      " echo "end function: " . string(crt_function)
      unlet crt_function
    endif

  endwhile

  " 2- second pass: locate where the functions are used
  let g:deps = deps
  let re_fns = join(lh#list#transform(deps, [], '"\\<".v:1_.name."\\>"'), '\|')
  let re_fns = substitute(re_fns, 's:', '\\%(s:\\|<[sS][iI][dD]>\\)', 'g')
  " let re_fns = '\%('.re_fns.'\)\ze\s*('
  let re_fns = '\%('.re_fns.'\)\ze'
  " let g:re_fns = re_fns

  let callers = []

  let i = 0
  while i != N
    silent! unlet caller
    let i = lh#list#match(lines, re_fns, i)
    if i == -1 | break | endif
    " echomsg "line ".i." -> ".string(re_fns)


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
      " TODO: use lh#list#find_fast
      for fn in deps
        if fn.range.begin < i && i < fn.range.end
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
function! s:Name(function) abort
  let name = a:function.kind == 'function'
        \ ? (a:function.name)
        \ : (a:function.kind) . (a:function.line)
  return name
endfunction

" Function: s:GetCalleeInfo(callee_name, deps) {{{3
function! s:GetCalleeInfo(callee_name, deps) abort
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
        \ || ( has_key(a:fn_data, 'range') && a:fn_data.range.begin <= a:line && a:line <= a:fn_data.range.end)
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

" Function: s:TagExposedFunctions(prefix, deps [, callees]) {{{3
function! s:TagExposedFunctions(prefix, deps, ...) abort
  let origin_fns = []
  let callees = []
  if empty(a:000)
    for caller in filter(copy(a:deps), 'v:val.kind =~ "map\\|abbr\\|menu\\|command\\|script"')
      let callees += caller.callees
    endfor
  else
    let callees = a:000
  endif

  for callee_name in callees
    let callee = s:GetCalleeInfo(callee_name, a:deps)[0]
    " if empty => error
    " echo string(callee)
    if !has_key(callee, 'name')
      echo "ignoring ".s:Name(callee)
    else
      call add(origin_fns, callee)
      if !has_key(callee, 'new_name')
        let callee.new_name = s:ComputeNewName(a:prefix, callee.name)
      endif
    endif
  endfor
  return origin_fns
endfunction

" Function: s:ComputeNewName(prefix, old_name) {{{3
function! s:ComputeNewName(prefix, old_name) abort
  let new_name = a:prefix.'#'.lh#naming#to_underscore(substitute(a:old_name, '^s:', '_', ''))
  echo a:old_name . ' -> ' . new_name
  return new_name
endfunction

" Function: s:UpdateFunctionRange(func, cached_lines) {{{3
function! s:UpdateFunctionRange(func, cached_lines) abort
  let lines = reverse(a:cached_lines[ : a:func.range.begin - 2])
  let idx = lh#list#find_if_fast(lines, 'v:val !~ "^\\s*\""')
  " echomsg func.name . "() starts at " .func.range.begin . " -- comment: -" .idx
  let a:func.range.comm_begin = a:func.range.begin - idx

  let lines = a:cached_lines[a:func.range.end : ]
  let idx = lh#list#find_if_fast(lines, 'v:val !~ "^\\s*$"')
  let a:func.range.comm_end = a:func.range.end + idx

  return a:func
endfunction

" s:MoveToAutoload {{{4
" [a:1] optional name of the autoload plugin
" [a:*] List of functions to move
function! s:MoveToAutoload(...) abort
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
  let a000 = a:000
  let fname = get(a000, 0, '')
  if empty(fname)
    let fname = expand('%:p')
    let ft = matchstr(fname, 'ftplugin/\zs[^/._]*')
    let fname = substitute(fname, 'ftplugin/.*\<'.ft.'\(\>\|_\)\ze.*\.vim', 'autoload/lh/'.ft.'/', '')
    " echomsg "ft: ".ft
    " echomsg "fname: ".fname
  else
    ""if fname !~ 'autoload'
    ""  let fname = 'autoload/'.fname
    ""endif
    ""call remove(a000, 0)
  endif
  let prefix = substitute(fname, '.*/autoload/\(.*\)\.vim$', '\1', '')
  let prefix = substitute(prefix, '/', '#', 'g')
  " echomsg "go into ".fname . "  (".prefix.")"

  " 0.3- determine the new name of the main function moved
  "
  " 1- determine the functions to move
  " 1.1- shall be able to work on a selected range, a function name, or all
  " functions from a script (plugin, ftplugin)
  " Let's say that default = every function from the script
  " 1.2- determine the exposed functions to move, and their new name
  " Check maps, commands, script variables, abbrs, and menus for functions that
  " need to be exposed.
  let exported_functions = call('s:TagExposedFunctions', [prefix, deps]+a000)

  " Functions names
  let repl = {}
  for func in exported_functions
    let repl[func.name] = func.new_name
  endfor

  " echomsg string(exported_functions)
  if confirm("Shall we move ".join(keys(repl), ', ')." functions into ".fname.' ('.prefix.'#*) ?', "&Yes\n&No", 1) != 1
    call lh#common#warning_msg('Aborting...')
    return
  endif


  " 1.3- determine the dependant functions (just in case ?)
  " -> functions that use them      \ _  graph!
  " -> internal functions they call /
  " => TODO
  "
  " 2- where they are used: change their reference name
  " 2.5- check everything is consistant: i.e. a function moved, but that stays
  " internal shall not be referenced anymore.
  let pattern = '\v%('.join(keys(repl), '|').')'
  exe '%s/'.pattern.'/\=repl[submatch(0)]/gc'

  " 2.?- what about comments ?
  " Let's cheks lines befores
  let all_lines = getline(1, '$')
  call lh#assert#value(all_lines).not().empty()
  for func in exported_functions
    call s:UpdateFunctionRange(func, all_lines)
  endfor

  " 3- move the funtions
  " Sort them in reverse order for cutting purposes
  call lh#list#sort(exported_functions, { a,b -> b.range.begin - a.range.end })
  echomsg string(exported_functions)

  let extracted_lines = []
  for func in exported_functions
    let extracted_lines = all_lines[func.range.comm_begin-1 : func.range.comm_end-1] + extracted_lines
    exe func.range.comm_begin .','. func.range.comm_end . 'd_'
  endfor
  call lh#buffer#jump(fname, 'vsp')
  $put=extracted_lines
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
