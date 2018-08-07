"=============================================================================
" File:         autoload/lh/markdown/toc.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.2
let s:k_version = 002
" Created:      10th Jul 2017
" Last Update:  24th Apr 2018
"------------------------------------------------------------------------
" Description:
"       Supports functions for ftplugin/markdown_githubtoc.vim
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
function! lh#markdown#toc#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#markdown#toc#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#markdown#toc#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API functions {{{1
" Function: lh#markdown#toc#_generate() {{{2
function! lh#markdown#toc#_generate() abort range
  let lines = getline(a:firstline, a:lastline)
  " First remove blocks of code
  let blocks = map(copy(lines), 'v:val =~ "^\\s*```" ? v:key : -1')
  call filter(blocks, 'v:val > 0')
  if len(blocks) % 2 != 0
    throw "Uneven number of code block tags (```) found, at lines: ".join(block, ', ')
  endif
  call reverse(blocks)
  for blk_idx in range(len(blocks)/2)
    call s:Verbose("Remove block [%1, %2]", blocks[blk_idx*2+1], blocks[blk_idx*2])
    call remove(lines, blocks[blk_idx*2+1], blocks[blk_idx*2])
  endfor
  " Then, keep only lines starting with a #
  " TODO, support lines unserlines by `===` , `---`, etc
  call filter(lines, 'v:val =~ "^#"')
  " Build pair title + url
  let titles = map(copy(lines), "split(v:val, '^\\v#+\\zs\\s+\\ze')")
  call map(titles, 'v:val + [v:val[-1]]')
  " Remove unsupported characters from URL
  call lh#list#map_on(titles, 1, 'substitute(v:val, "\\v[^-A-Za-z-1-9_ ÀÂÄÉÈÊËÏÎÜÛÖÔÇàâäéèêëïîüûöôç]", "", "g")' )
  call lh#list#map_on(titles, 1, 'substitute(v:val, "\\v\\s+", "-", "g")' )
  " force URL into lower characters
  call lh#list#map_on(titles, 1, 'tolower(v:val)' )
  " Extract depth
  call lh#list#map_on(titles, 0, 'substitute(v:val, "\\v.*", "\\=strlen(submatch(0))", "")' )
  let level_min = min(lh#list#get(titles, 0)) - 1
  let t2 = lh#list#map_on(deepcopy(titles), 0, 'repeat("    ", v:val -'.level_min.') . "* "')
  let toc = map(copy(t2), 'v:val[0]."[".v:val[2]."](#".v:val[1].")"')
  put=toc
endfunction


"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
