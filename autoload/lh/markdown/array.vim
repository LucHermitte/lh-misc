"=============================================================================
" File:         autoload/lh/markdown/array.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPL w/ exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      25th May 2018
" Last Update:  28th May 2018
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

  if     pos == 1
    return empty(ArgLead) ? keys(s:k_subcommands) : filter(keys(s:k_subcommands), 'v:val =~ "^".ArgLead')
  elseif pos == 2
    return lh#command#matching_variables(ArgLead)
  endif
  return []
endfunction

" Function: lh#markdown#array#_command(line1, line2, cmd, ...) {{{2
function! lh#markdown#array#_command(line1, line2, ...) abort
  if a:0 == 0
    call lh#common#warning_msg(
          \ [ ':Array USAGE:'
          \ , '   [range] Array load-into {varname}                                    -- loads array in variable {varname}'
          \ , '   [range] Array align [{varname}]                                      -- aligns cols of array'
          \ , '   [range] Array delete-col {col-spec} [{varname}]                      -- remove columns specified by {col-spec}, e.g.: "1,2:5,8:"'
          \ , '   [range] Array merge-new-col {array-varname} {col-varname} [{col nr}] -- add a new column indexed by the first'
          \ ])
    return
  endif
  let l:Cmd = get(s:k_subcommands, a:1, lh#option#unset())
  if lh#option#is_unset(l:Cmd)
    throw "Unsupported command. Please select among ".string(keys(s:k_subcommands))
  endif

  if s:verbose >= 2
    debug call call(l:Cmd, [a:line1, a:line2]+a:000[1:])
  else
    call call(l:Cmd, [a:line1, a:line2]+a:000[1:])
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

function! s:is_rectangular(array) abort " {{{2
  return len(uniq(map(copy(a:array), 'len(v:val)'))) == 1
endfunction

function! s:load_array(line1, line2) abort " {{{2
  let lines = getline(a:line1, a:line2)
  " Expect no non-array lines in the range

  " TODO: support embedded pipes like in
  "    | col1 | `|'isk'|` | col3 |
  let array = map(lines, 'split(v:val, "\\s*|\\s*")')
  " Expect the array non empty, and rectangular
  call lh#assert#value(array).not().empty()
  call lh#assert#value(array).verifies(function('s:is_rectangular'))
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

function! s:fill_col_lens(lens, col, cell) abort " {{{2
  call lh#assert#value(len(a:lens)).is_gt(a:col)
  call add(a:lens[a:col], lh#encoding#strlen(a:cell))
  return a:cell
endfunction

""function! s:fill_lens_from_line(lens, line) abort " {{{2
""  let l2 = map(copy(a:line), 's:fill_col_lens(a:lens, v:key, v:val)')
""  call lh#assert#value(l2).eq(a:line)
""  return a:line
""endfunction

function! s:repeat(value, size) abort " {{{2
   " NB: we cannot use repeat() otherwise, all sublists will be point to the
   " same list
  let res = []
  call map(range(a:size), 'add(res, copy(a:value))')
  return res
endfunction

function! s:array_to_stringlist(array) abort " {{{2
  " 1. max length of each row
  let lens = s:repeat([], len(a:array[0]))
  " let g:lens = lens

  call map(deepcopy(a:array), { l,line -> map(line, {c, cell -> s:fill_col_lens(lens, c, cell)})})
  " let g:array2 = map(copy(a:array), 's:fill_lens_from_line(lens, v:val)')
  call lh#assert#value(len(lens[0])).eq(len(a:array))
  let max_len_per_col = map(copy(lens), 'max(v:val)')
  let g:max_len_per_col = max_len_per_col

  " 2. resize each cel in each row
  call map(a:array, { l,line -> map(line, {c, cell -> cell . repeat(' ', max_len_per_col[c]-lens[c][l])})})

  " 3. each line -> string
  return map(deepcopy(a:array), '"| ".join(v:val, " | ")." |"')
endfunction

function! s:get_col(array, c) abort " {{{2
  let col = map(copy(a:array), {l, line -> line[a:c]})
  return col
endfunction

" Function: s:align(line1, line2) {{{2
function! s:align(line1, line2, ...) abort
  echomsg ("Aligning...")
  if a:0 > 0
    if !exists(a:1)
      throw "No variable named '".a:1."' exists"
    endif
    let array = {a:1}
  else
    let array = s:load_array(a:line1, a:line2)
  endif
  let sarray = s:array_to_stringlist(array)
  call setline(a:line1, sarray)
endfunction

" Function: s:delete_col(line1, line2, ...) {{{2
function! s:delete_col(line1, line2, ...) abort
  let a000 = a:000

  if a:0 > 0
    if a:1 !~ '\v^\d+$'
      if !exists(a:1)
        throw "No variable named '".a:1."' exists"
      endif
      let array_name = remove(a000, 0)
      let array = {array_name}
    else
      let array = s:load_array(a:line1, a:line2)
    endif
    " Expect all lines to have the same size...
  endif
  let specs = call('s:col_specs', ['remove'] + a000)

  let keep_specs = s:reverse_specs(specs, len(array[0]))
  call s:Verbose("Columns to keep: %1", keep_specs)

  let sspec = join(map(keep_specs, '"v".":val[".v:val."]"'), '+')
  call s:Verbose("Expression to apply on lines: %1", sspec)

  call map(array, sspec)

  if exists('array_name')
    call lh#let#to(a:1, array)
  else
    let sarray = s:array_to_stringlist(array)
    call setline(a:line1, sarray)
  endif
endfunction

" Function: s:load_into(line1, line2, array_name) abort {{{2
function! s:load_into(line1, line2, array_name) abort
  let array = s:load_array(a:line1, a:line2)
  call lh#let#to(a:array_name, array)
endfunction

" Function: s:merge_new_col(line1, line2, array_varname, col_varname, ...) abort {{{2
function! s:merge_new_col(line1, line2, array_varname, col_varname, ...) abort
  let col_nr = get(a:, 1, -1)

  " TODO: cehck variables exist
  if !exists(a:array_varname)
    throw "No variable named '".a:array_varname."' exists"
  endif
  if !exists(a:col_varname)
    throw "No variable named '".a:col_varname."' exists"
  endif
  let array = {a:array_varname}
  let col   = {a:col_varname}

  " let index0 = s:get_col(array, 0)
  let arr_dict = {}
  call map(copy(array), {l, line -> extend(arr_dict, {tolower(line[0]): copy(line)})})
  let col_dict = {}
  call map(copy(col),   {l, line -> extend(col_dict, {tolower(line[0]): line[1]})})

  " concurrent iteration index0 , keys(col_dict)
  " - if key{col_dict} not in index0 => add line in array
  let keys = lh#list#unique_sort(map(keys(arr_dict) + keys(col_dict), 'tolower(v:val)'))
  let g:keys = keys
  let nb_cols = len(array[0])
  let res_array = map(copy(keys), 'has_key(arr_dict, v:val) ? arr_dict[v:val] : [v:val] + s:repeat("-", nb_cols-1)')

  call map(res_array, {l, line -> insert(line, get(col_dict, tolower(line[0]), '-'), col_nr) })
  call lh#let#to(a:array_varname, res_array)
endfunction

" Sub-command list {{{2
let s:k_subcommands =
      \ { 'align'        : function('s:align')
      \ , 'delete-col'   : function('s:delete_col')
      \ , 'load-into'    : function('s:load_into')
      \ , 'merge-new-col': function('s:merge_new_col')
      \ }

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
