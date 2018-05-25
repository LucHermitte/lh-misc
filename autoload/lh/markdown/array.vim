"=============================================================================
" File:         autoload/lh/markdown/array.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL w/ exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      25th May 2018
" Last Update:  25th May 2018
"------------------------------------------------------------------------
" Description:
"       Utilities to modify arrays
"       (support functions)
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#markdown#array#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#markdown#array#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#markdown#array#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API      functions {{{1
" Function: lh#markdown#array#_complete(ArgLead, CmdLine, CursorPos) {{{2
function! lh#markdown#array#_complete(ArgLead, CmdLine, CursorPos) abort
  let [pos, tokens, ArgLead, CmdLine, CursorPos] = lh#command#analyse_args(a:ArgLead, a:CmdLine, a:CursorPos)
  " call s:Verbose("pos: %1, ArgLead: %2", pos, ArgLead)

  if pos == 1
    return empty(ArgLead) ? keys(s:k_subcommands) : filter(keys(s:k_subcommands), 'ArgLead =~ v:val')
  endif
  return []
endfunction

" Function: lh#markdown#array#_command(line1, line2, cmd, ...) {{{2
function! lh#markdown#array#_command(line1, line2, cmd, ...) abort
  let l:Cmd = get(s:k_subcommands, a:cmd, lh#option#unset())
  if lh#option#is_unset(l:Cmd)
    throw "Unsupported command. Please select among ".string(keys(s:k_subcommands))
  endif

  call call(l:Cmd, [a:line1, a:line2]+a:000)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

function! s:load_array(line1, line2) abort " {{{2
  let lines = getline(a:line1, a:line2)
  " Expect no non-array lines in the range

  let array = map(lines, 'split(v:val, "\\s*|\\s*")')
  " Expect the array non empty, and rectangular
  call s:Verbose("Array is %1l x %2c", len(array), len(array[0]))
  return array
endfunction

function! s:col_specs(what, ...) abort " {{{2
  " TODO: sort column specifications
  if a:0 == 0
    throw "Please specify slices of column numbers to ".a:what.". e.g. 1,2:5,8:"
  endif
  let specs = lh#list#flatten(map(copy(a:000), 'split(v:val, "\\s*,\\s*")'))
  call s:Verbose("Columns to %1: %2", a:what, specs)
  return specs
endfunction

function! s:reverse_specs(specs, max) abort " {{{2
  let specs = []
  let last = -1
  for sp in a:specs
    if sp =~ '^\d\+$'
      let c1 = eval(sp)
      let c2 = c1
    elseif sp =~ '\v^\s*(\d+\s*)?:\s*(\d+\s*)?$'
      let [c1; r2] = split(sp, '\s*:\s*')
      let c1 = empty(c1) ? 0  : eval(c1)
      let c2 = empty(r2) ? a:max : eval(r2[0])
    else
      throw "Invalid colunm range specifier: ".sp
    endif

    " call lh#assert#value(c1).is_gt(last)
    " call lh#assert#value(c1).is_le(c2)
    if     c1 - last == 1
      " ignore
    " elseif c1 - last == 2
      " let specs += [(last + 1) .':'. (c1 - 1)]
    else
      let specs += [(last + 1) .':'. (c1 - 1)]
    endif

    let last = c2
  endfor

  if a:max - last > 1
    let specs += [(last+1).':']
  endif
  return specs
endfunction

function! s:array_to_stringlist(array) abort
  " 1. max length of each row
  let lens = repeat([[]], len(a:array[0]))
  let g:lens = lens

  call map(deepcopy(a:array), { i,line -> map(line, {c, cell -> add(lens[c], lh#encoding#strlen(cell))})})
  call lh#assert#value(len(lens[0])).eq(len(a:array))
  " call map(lens, 'max(v:val)')

  " 2. resize each row
  " 3. each line -> string
  return map(deepcopy(a:array), '"| ".join(v:val, " | ")." |"')
endfunction

" Function: s:align(line1, line2) {{{2
function! s:align(line1, line2) abort
  echomsg ("Aligning...")
  let array = s:load_array(a:line1, a:line2)
  let sarray = s:array_to_stringlist(array)
  call setline(a:line1, sarray)
endfunction

" Function: s:delete_col(line1, line2, ...) {{{2
function! s:delete_col(line1, line2, ...) abort
  let specs = call('s:col_specs', ['remove'] + a:000)

  let array = s:load_array(a:line1, a:line2)
  " Expect all lignes to have the same size...

  let keep_specs = s:reverse_specs(specs, len(array[0]))
  call s:Verbose("Columns to keep: %1", keep_specs)

  let sspec = join(map(keep_specs, '"v".":val[".v:val."]"'), '+')
  call s:Verbose("Expression to apply on lines: %1", sspec)

  call map(array, sspec)
  let sarray = s:array_to_stringlist(array)
  call setline(a:line1, sarray)
endfunction


let s:k_subcommands = {
      \ 'align'      : function('s:align'),
      \ 'delete-col' : function('s:delete_col')
      \ }

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/markdown/«markdown_array».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
