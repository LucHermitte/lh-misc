"=============================================================================
" $Id$
" File:		plugin/rotate_substitute.vim                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.0.0
" Created:	27th Nov 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" <http://stackoverflow.com/questions/1809571/how-do-i-substitute-from-a-list-of-strings-in-vim>
" 
"------------------------------------------------------------------------
" Installation:	
" Drop the file into {rtp}/plugin
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_rotate_substitute") && !exists('g:force_reload_rotate_substitute'))
  finish
endif
let g:loaded_rotate_substitute = 100
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
:command! -bang -nargs=1 -range RotateSubstitute <line1>,<line2>call s:RotateSubstitute("<bang>", <f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1

function! s:RotateSubstitute(bang, repl_arg) range
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
  let cmd = a:firstline . ',' . a:lastline . 's' . sep . join(args, sep)
  " echom cmd
  " and run it
  exe cmd
endfunction

function! s:DoRotateSubst(do_loop, list, replaced, ...)
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
      let res .= ml[1]
      let ref = eval(substitute(ml[2], '\\\(\d\+\)', 'a:\1', ''))
      let res .= ref
      let res0 = ml[3]
    endwhile

    return res
  endif
endfunction

" %RotateSubstitute/\(.\)foo\(.\)/\2bar\1/\1bar\2/
" AfooZ
" BfooE
" CfooR
" DfooT

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
