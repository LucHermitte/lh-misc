"=============================================================================
" File:		footnote.vim
" Authors:	<emmanuel.touzery at wanadoo.fr>, <mikmach at wp.pl>,
" 		and <salmanhalim at hotmail.com>
" 		<URL:http://vim.sf.net/ vim tip # 332>
" 		<EMAIL: hermitte at free.fr>
" URL: http://hermitte.free.fr/vim/ressources/vimfiles/plugin/footnote.vim
" Version:	2.0
" Created:	24th sep 2002
" Last Update:	27th sep 2002
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	Drop it into your $$/plugin/ directory.
" History: {{{
"	1.x : Emmanuel Touzery, mikmach and salmanhalim of SF
" 	2.0 : Luc Hermitte :
" 		* pluginization of the script
" 		* some options to start the counting at any desired value.
" 		* edition of the footnote in a separate window.
" }}}
" TODO:		«missing features»
"=============================================================================
"
" Avoid reinclusion
" 
if exists("g:loaded_footnote_vim") 
  finish 
endif
let g:loaded_footnote_vim = 1
let s:cpo_save=&cpo
set cpo&vim
"
"========================================================================
" Mappings {{{
if !hasmapto('<Plug>AddVimFootnote', 'i')
  imap <C-X>f <Plug>AddVimFootnote
endif
if !hasmapto('<Plug>AddVimFootnote', 'n')
  nmap <leader>af <Plug>AddVimFootnote
endif
nnoremap <Plug>AddVimFootnote :call <sid>VimFootnotes('a')<cr>
inoremap <Plug>AddVimFootnote <c-o>:call <sid>VimFootnotes('i')<cr>
" inoremap ,r <esc>:exe b:pos<cr> 
" Mappings }}}
"========================================================================
" Options {{{
"---------------------------------------------------------------
" Function: s:SetVar() to global or default {{{
function! s:SetVar(var,default)
  if     exists('b:'.a:var) | let s:{a:var} = b:{a:var}
  elseif exists('g:'.a:var) | let s:{a:var} = g:{a:var}
  else                      | exe "let s:{a:var} =".a:default
    " Rem: doing :exe to dequote a:default
  endif
endfunction
command! -nargs=+ SetVar :call <sid>SetVar(<f-args>)
" }}}
"---------------------------------------------------------------
SetVar first_footnote 1

if exists('g:vim_footnote_in_splitted_window')
  if     g:vim_footnote_in_splitted_window == 0
    let s:splitted_window = "0"
  elseif g:vim_footnote_in_splitted_window == 1
    let s:splitted_window = ''
  elseif g:vim_footnote_in_splitted_window == 2
    let s:splitted_window = 'below'
  elseif g:vim_footnote_in_splitted_window == 3
    let s:splitted_window = 'above'
  endif
else
  let s:splitted_window = 'below'
endif
" 0 => not in a splitted window
" 1 => in a splitted window placed according to &splitbelow
" 2 => the splitted window is always placed below the current one
" 3 => the splitted window is always placed above the current one
"
"---------------------------------------------------------------
delcommand SetVar
" Options }}}
"========================================================================
" Main function {{{
function! s:VimFootnotes(appendcmd) 
  " Inc. footnote number {{{
  if exists("b:vimfootnotenumber") 
    let b:vimfootnotenumber = b:vimfootnotenumber + 1 
    let cr = "" 
  else 
    let b:vimfootnotenumber = s:first_footnote 
    let cr = "\<cr>" 
  endif " }}}
  " Check how the footnote is edited {{{
  if s:splitted_window != "0"
    exe ":" . s:splitted_window . " 3sp"
  else
    let b:pos = line('.').' | normal! '.virtcol('.').'|'.'4l' 
  endif " }}}
  exe "normal ".a:appendcmd."[".b:vimfootnotenumber."]\<esc>G" 
  if search("-- $",  "b") 
    exe "normal O".cr."[".b:vimfootnotenumber."] "
  else 
    exe "normal o".cr."[".b:vimfootnotenumber."] "
  endif 
  startinsert!
endfunction 
" Main function }}}
"========================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
