"=============================================================================
" File:         ftplugin/markdown_githubtoc.vim                   {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.1.
let s:k_version = 001
" Created:      24th Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       Generate TOC for a github markdown file
"
" Run for instance:
"   :1,$Toc
" where you want the TOC inserted
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_markdown_githubtoc")
      \ && (b:loaded_ftplug_markdown_githubtoc >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_githubtoc'))
  finish
endif
let b:loaded_ftplug_markdown_githubtoc = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=0 -range=% Toc <line1>,<line2>call s:Toc()

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_markdown_githubtoc")
      \ && (g:loaded_ftplug_markdown_githubtoc >= s:k_version)
      \ && !exists('g:force_reload_ftplug_markdown_githubtoc'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_markdown_githubtoc = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/markdown/«markdown_githubtoc».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Function: s:Toc() {{{3
function! s:Toc() abort range
  let lines = getline(a:firstline, a:lastline)
  call filter(lines, 'v:val =~ "^#"')
  let titles = map(copy(lines), "split(v:val, '^\\v#+\\zs\\s+\\ze')")
  call map(titles, 'v:val + [v:val[-1]]')
  call lh#list#map_on(titles, 1, 'substitute(v:val, "\\v[^-A-Za-z-1-9_ ]", "", "g")' )
  call lh#list#map_on(titles, 1, 'substitute(v:val, "\\v\\s+", "-", "g")' )
  call lh#list#map_on(titles, 1, 'tolower(v:val)' )
  call lh#list#map_on(titles, 0, 'substitute(v:val, "\\v.*", "\\=strlen(submatch(0))", "")' )
  let level_min = min(lh#list#get(titles, 0)) - 1
  let t2 = lh#list#map_on(deepcopy(titles), 0, 'repeat("  ", v:val -'.level_min.') . "* "')
  let toc = map(copy(t2), 'v:val[0]."[".v:val[2]."](#".v:val[1].")"')
  put=toc
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
