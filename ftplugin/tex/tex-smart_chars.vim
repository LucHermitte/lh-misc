"=============================================================================
" File:         ftplugin/tex/tex-smart_chars.vim                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      2.0.0
let s:k_version = 200
" Created:      2004
" Last Update:  20th Jan 2019
"------------------------------------------------------------------------
" Description:
" VIM Macros for editing LaTeX documents
"
" The macros and mappings provided in this file are smart :
" - quotes are automatically converted to the LaTeX sequences for quotes
"   regarding your language
" - '_' is expanded into '\_' outside of Mathematical modes
" - '__' is expanded into '_{}^{}' inside Math modes.
" - '...' results in \dots ; comment out to activate
" - <BS> recognizes accentuaded letters and delete them in one key-press
"
" NB: These macros have been "borrowed" from other vim macro files and
" adapted.
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_tex_smart_chars")
      \ && (b:loaded_ftplug_tex_smart_chars >= s:k_version)
      \ && !exists('g:force_reload_ftplug_tex_smart_chars'))
  finish
endif
let b:loaded_ftplug_tex_smart_chars = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Required function {{{2
" ================= getSNR =============================== {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

" Local Settings {{{2
  let b:tex_smart_chars__maps_loaded = 1

  let b:ModeLine_CallBack = "TeXModeLine_CallBack"

" Local mappings {{{2

inoremap <buffer> _ <C-R>=<SID>SubSuper()<CR>
inoremap <buffer> " "<Left><C-O>:let@9=<SID>TeX_quote()<CR><Del><C-R>9
"inoremap <buffer> . <C-R>=<SID>Dots()<CR>
"inoremap <buffer> <M-.> .

call lh#brackets#define_imap('<bs>',
      \ [{ 'condition': 'lh#brackets#_match_any_bracket_pair()',
      \   'action': 'lh#brackets#_delete_empty_bracket_pair()'}],
      \ 1,
      \ '\<C-R\>='.s:getSNR('SmartBS()').'\<CR\>'
      \ )

"------------------------------------------------------------------------
" Local commands {{{2

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_tex_smart_chars")
      \ && (g:loaded_ftplug_tex_smart_chars >= s:k_version)
      \ && !exists('g:force_reload_ftplug_tex_smart_chars'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_tex_smart_chars = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/tex/«tex_smart_chars».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" ================= Underscore Macros ==================== {{{3
" In Math mode, _   results in _
"               __  results in _{}^{}
" Otherwise,    _   results in \_
" Inspired from AUCTEX.vim
function! s:IDof(delta)
  return synIDattr(synID(line('.'),col('.')+a:delta,0),"name")
endfunction

function! s:SubSuper ()
  let syn = <SID>IDof(-1)
  let li   = getline(line("."))
  let left = li[col(".")-2]
  if syn =~ "^texMath"
    if left == '_'
      if exists("b:usemarks") && b:usemarks
        return lh#map#build_map_seq('{}^{!mark!}!mark!\<ESC>2F{a')
      else
        return "{}^{}\<Esc>F}i"
      endif
    endif
    return '_'
  elseif (left == "$") && ((<SID>IDof(0) =~ "^texMath") || li[col(".")-1]=="$")
    " todo: support \Q{} as well
    return '_'
  else
    return '\_'
  endif
endfunction

" ================= Quote Macros ========================= {{{3
" From texmacros.vim by Benji Fisher <benji@member.AMS.org>
"
" 1.  Quoting style:  the default is ``English.''
" Use TeX_strictquote = "open" if you want open quotes
" to be ignored unless they immediately precede an alphabetic character.
" Other options are "close" and "both".

" French <<quotations>> ; ? utiliser avec la version commerciale de French
" uniquement -- French par B. Gaulle
" let TeX_open = "<<"
" let TeX_close = ">>"
" French <<quotations>> ; pour latin1, en attendant de faire fonctionner aeguill
" \og, et \fg sont mieux car ils g?rent les espaces correctement, avec Babel
 let TeX_open = "?"
 let TeX_close = "?"
" German (?) >>quotations<<
" let TeX_open = ">>"
" let TeX_close = "<<"
" Polish ,,quotations''--use strictquote to avoid problems with ",,".
" let TeX_open = ",,"
" let TeX_close = "''"
" let TeX_strictquote = "open"

" Assume the cursor is on a " and return TeX-style open quotes or close
" quotes appropriately.
" TODO:  Deal with nested quotes.
function! s:TeX_quote()
  let l = line(".")
  let c = col(".")
  if synIDattr(synID(l, c, 1), "name") =~ "^texMath"
            \ || (c > 1 && getline(l)[c-2] == '\')
    return '"'
  endif
  if exists("g:TeX_open") | let open = g:TeX_open
  else                    | let open = "``"
  endif
  if exists("g:TeX_close") | let close = g:TeX_close
  else                     | let close = "''"
  endif
  let boundary = '\|'
  if exists("g:TeX_strictquote")
    if( g:TeX_strictquote == "open" || g:TeX_strictquote == "both" )
      let boundary = '\<' . boundary
    endif
    if( g:TeX_strictquote == "close" || g:TeX_strictquote == "both" )
      let boundary = boundary . '\>'
    endif
  endif
  let q = open
  let ws_save = &wrapscan
  set wrapscan  " so the search will not fail
  while 1       " Look for preceding quote (open or close), ignoring
                " math mode and '\"' .
    execute 'normal ?^$\|"\|' . open . boundary . close . "\r"
    if synIDattr(synID(line("."), col("."), 1), "name") !~ "^texMath"
            \ && (col(".") == 1 || getline(".")[col(".")-2] != '\')
      break
    endif
  endwhile
  " Now, test whether we actually found a _preceding_ quote; if so, is it
  " and open quote?
  if ( line(".") < l || line(".") == l && col(".") < c )
    if strlen(getline("."))
      if ( getline(".")[col(".")-1] == open[0] )
        let q = close
      endif
    endif
  endif
  " Return to line l, column c:
  execute l . " normal " . c . "|"
  let &wrapscan = ws_save
  return q
endfunction

" ================= Dots ================================= {{{3
" Typing ... results in \dots
" Use this if you want . to result in a period followed by 2 spaces.
" Originally by ... ? Do not remember
function! s:Dots ()
    let column = col(".")
    let currentline = getline(line("."))
    let previous = currentline[column-2]
    if strpart(currentline,column-4,3) == ".  "
        return "\<BS>\<BS>"
    elseif previous == '.'
        return "\<BS>\\dots"
    elseif previous =~ '[\$A-Za-z]' && currentline !~ "@"
        return ". "
    else
        return "."
    endif
endfunction

" ================= SmartBS ============================== {{{3
" SmartBS: smart backspacing
" SmartBS lets you treat diacritic characters (those \'{a} thingies) as a
" single character. This is useful for example in the following situation:
"
" \v{s}\v{t}astn\'{y}    ('happy' in Slovak language :-) )
" If you will delete this world normaly (withouth using smartBS()
" function), you must press <BS> about 19x. With function smartBS() you
" must press <BS> only 7x. Strings like "\v{s}", "\'{y}" are considered
" like one character and are deleted with one <BS>.
"
let g:smartBS_tex = '\(' .
                        \ "\\\\[\"^'=v]{\\S}"      . '\|' .
                        \ "\\\\[\"^'=]\\S"         . '\|' .
                        \ '\\v \S'                 . '\|' .
                        \ "\\\\[\"^'=v]{\\\\[iI]}" . '\|' .
                        \ '\\v \\[iI]'             . '\|' .
                        \ '\\q \S'                 . '\|' .
                        \ '\\-'                    .
                        \ '\)' . "$"

" This function comes from Benji Fisher <benji@e-math.AMS.org>
" http://vim.sourceforge.net/scripts/download.php?src_id=409
" (modified/patched by Lubomir Host 'rajo' <host8 AT keplerDOTfmphDOTuniba.sk>)
function! s:SmartBS()
  let init = strpart(getline("."), 0, col(".")-1)
  let matchtxt = matchstr(init, g:smartBS_tex)
  if matchtxt != ''
    let bstxt = substitute(matchtxt, '.', "\<bs>", 'g')
    return bstxt
  else
    return "\<bs>"
  endif
endfun

" Functions }}}2
"}}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
