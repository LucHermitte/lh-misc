"=============================================================================
" File:         plugin/rotate_substitute.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" Version:      1.0.4
" Created:      27th Nov 2009
" Last Update:  10th Oct 2023
"------------------------------------------------------------------------
" Description:
"   CycleSubstitute: <http://stackoverflow.com/questions/1809571/how-do-i-substitute-from-a-list-of-strings-in-vim>
"   Tr:              <http://stackoverflow.com/a/25665554/15934>
"   See Also:        <https://vi.stackexchange.com/a/15546/626>
"
"------------------------------------------------------------------------
" Installation:
" Drop the file into {rtp}/plugin
" History:
"       v1.0.4:
"       * Add 'g' flag to RotateSubstitute
"       v1.0.3:
"       * +:Translate
"       v1.0.2:
"       * CycleSubstitute fixed to support: CycleSubstitute/title/subtitle
" TODO:         �missing features�
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_rotate_substitute") && !exists('g:force_reload_rotate_substitute'))
  finish
endif
let g:loaded_rotate_substitute = 103
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
:command! -bang -nargs=1 -range CycleSubstitute <line1>,<line2>call s:CycleSubstitute("<bang>", <f-args>)
:command! -bang -nargs=1 -range RotateSubstitute <line1>,<line2>call s:RotateSubstitute("<bang>", <f-args>)
:command! -nargs=1 -range=1 Translate <line1>,<line2>call s:Translate(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1

" ~ swap, see togle stuff
" no back ref supported; makes no sense
function! s:CycleSubstitute(bang, repl_arg) range abort
  let do_loop = a:bang != "!"
  let sep = a:repl_arg[0]
  let fields = split(a:repl_arg, sep)
  let cleansed_fields = map(copy(fields), 'substitute(v:val, "\\\\[<>]", "", "g")')
  " build the action to execute
  let action = '\=s:DoCycleSubst('.do_loop.',' . string(cleansed_fields) . ', "^".submatch(0)."$")'
  " prepare the :substitute command
  let args = [join(fields, '\|'), action ]
  let cmd = a:firstline . ',' . a:lastline . 's'
        \. sep . join(fields, '\|')
        \. sep . action
        \. sep . 'g'
  " echom cmd
  " and run it
  exe cmd
endfunction

function! s:DoCycleSubst(do_loop, fields, what) abort
  let idx = (match(a:fields, a:what) + 1) % len(a:fields)
  return a:fields[idx]
endfunction

function! s:RotateSubstitute(bang, repl_arg) range abort
  let do_loop = a:bang != "!"
  " echom "do_loop=".do_loop." -> ".a:bang
  " reset internal state
  let s:rs_idx = 0
  " obtain the separator character
  let sep = a:repl_arg[0]
  " obtain all fields in the initial command
  let fields = split(a:repl_arg, sep)

  " prepare all the backreferences
  let replacements = fields[1:]
  let max_back_ref = 0
  for r in replacements
    let s = substitute(r, '.\{-}\(\\\d\+\)', '\1', 'g')
    " echo "s->".s
    let ls = split(s, '\\')
    for d in ls
      let br = matchstr(d, '\d\+')
      " echo '##'.(br+0).'##'.type(0) ." ~~ " . type(br+0)
      if !empty(br) && (0+br) > max_back_ref
        let max_back_ref = br
      endif
    endfor
  endfor
  " echo "max back-ref=".max_back_ref
  let sm = ''
  for i in range(0, max_back_ref)
    let sm .= ','. 'submatch('.i.')'
    " call add(sm,)
  endfor

  " build the action to execute
  let action = '\=s:DoRotateSubst('.do_loop.',' . string(replacements) . sm .')'
  " prepare the :substitute command
  let args = [fields[0], action ]
  let cmd = a:firstline . ',' . a:lastline . 's' . sep . join(args, sep) . sep . 'g'
  " echom cmd
  " and run it
  exe cmd
endfunction

function! s:DoRotateSubst(do_loop, list, replaced, ...) abort
  " echom string(a:000)
  if ! a:do_loop && s:rs_idx == len(a:list)
    return a:replaced
  else
    let res0 = a:list[s:rs_idx]
    let s:rs_idx += 1
    if a:do_loop && s:rs_idx == len(a:list)
        let s:rs_idx = 0
    endif

    let res = ''
    while strlen(res0)
      let ml = matchlist(res0, '\(.\{-}\)\(\\\d\+\)\(.*\)')
      if empty(ml)
        let res.=res0
        break
      endif
      let res .= ml[1]
      let ref = eval(substitute(ml[2], '\\\(\d\+\)', 'a:\1', ''))
      let res .= ref
      let res0 = ml[3]
    endwhile

    return res
  endif
endfunction

function! s:Translate(repl_arg) range abort
  let sep = a:repl_arg[0]
  let fields = split(a:repl_arg, sep)
  " build the action to execute
  " prepare the :global command
  let cmd = a:firstline . ',' . a:lastline . 'g'.sep.'.'.sep
        \. 'call setline(".", tr(getline("."), '.string(fields[0]).','.string(fields[1]).'))'
  " and run it
  " echom cmd
  exe cmd
endfunction

" %RotateSubstitute/\(.\)foo\(.\)/\2bar\1/\1bar\2/
" AfooZ
" BfooE
" CfooR
" DfooT



" %CycleSubstitute/A/B/C
" ABC
" BCA
" CAB



" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
