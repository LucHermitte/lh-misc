"=============================================================================
" $Id$
" File:         plugin/omap-any-bracket.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      0.0.2
" Created:      21st Dec 2010
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Mappings for selecting the first enclosing bracket pair.
"       -> di%, v3a%, etc
"
"       Answer to the question:
"       <http://unix.stackexchange.com/questions/4882/block-motion-for-any-bracket-type>
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/plugin
"       Requires Vim7+
" 	- {rtp}/autoload/lh/position.vim (lh-vim-lib v2.2.4)
" 	- {rtp}/autoload/lh/syntax.vim (lh-vim-lib)
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:k_version = 002
if &cp || (exists("g:loaded_omap_any_bracket")
      \ && (g:loaded_omap_any_bracket >= s:k_version)
      \ && !exists('g:force_reload_omap_any_bracket'))
  finish
endif
let g:loaded_omap_any_bracket = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Public Mappings {{{1
onoremap <silent> i% :<c-u>call <sid>SelectFirstPair(1,0)<cr>
xnoremap <silent> i% :<c-u>call <sid>SelectFirstPair(1,1)<cr><esc>gv
onoremap <silent> a% :<c-u>call <sid>SelectFirstPair(0,0)<cr>
xnoremap <silent> a% :<c-u>call <sid>SelectFirstPair(0,1)<cr><esc>gv
" Public Mappings }}}1
"------------------------------------------------------------------------
" Private Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«omap_any_bracket».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
let s:k_pairs = {
      \ '(': ')',
      \ '[': ']',
      \ '{': '}',
      \ '<': '>'
      \ }

let s:k_begin = '[([{<]'
let s:k_end   = '[)\]}>]'
  
function! s:SelectFirstPair(inner, visual)
  " In case we already are in visual mode, we may have to extend the current
  " zone if it selects a pair of brackets
  if a:visual
    let char_b = lh#position#char_at_mark("'<")
    if char_b =~ s:k_begin
	  \ && s:k_pairs[char_b] == lh#position#char_at_mark("'>")
      call search('.', 'bW') " previous char
    elseif a:inner
      " handle case the case "vi%i%i%"
      let current_pos = getpos('.')
      call setpos('.', getpos("'<"))
      call search('.', 'bW') " previous char
      let pos_b = getpos('.')
      call setpos('.', getpos("'>"))
      call search('.', 'W') " next char
      let pos_e = getpos('.')
      let char_b = lh#position#char_at_pos(pos_b)
      let char_e = lh#position#char_at_pos(pos_e)
      " echomsg "chars = ".char_b.char_e
      if char_b =~ s:k_begin
	    \ && s:k_pairs[char_b] == char_e
	call setpos('.', pos_b) " restore start_pos
	call search('.', 'bW') " previous char
      else
	call setpos('.', current_pos) " restore init_pos
      endif
    endif
  endif
  " Searching the n outer blocks requested
  let cnt = v:count <= 0 ? 1 : v:count
  while cnt > 0
    let cnt -= 1
    let char_c = lh#position#char_at_pos(getpos('.'))
    let accept_at_current = char_c =~ s:k_begin ? 'c' : ''

    " Begin of the current outer block
    if 0 ==searchpair(s:k_begin, '', s:k_end, 'bW'.accept_at_current, 'lh#syntax#skip()')
      throw "No outer bloc"
    endif
    if cnt > 0
      call search('.', 'bW') " previous char
    endif
  endwhile

  let char_b = lh#position#char_at_pos(getpos('.'))

  normal! v

  " End of the outer block
  let pos = searchpair(s:k_begin, '', s:k_end, 'W', 'lh#syntax#skip()')
  let char_e = lh#position#char_at_pos(getpos('.'))
  if pos == 0
    throw "pos == 0"
  elseif s:k_pairs[char_b] != char_e
    echomsg "unbalanced blocks"
  endif

  " Adjusting the extremities
  if a:inner
    call search('.', 'b')
    normal! o
    call search('.')
    normal! o
  endif
endfunction
" Private Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
