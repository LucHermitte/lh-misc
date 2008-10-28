" ========================================================================
" File:		block-indent.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim-beta>
"
" Last Update:	21st jul 2002
" Version:	1.1b
"
" Purpose:	Define VISUAL and NORMAL mode mapping to reindent correctly
" 		a group of lines. 
" 		<tab>		in NORMAL mode reindents the current line.
" 		<C-tab>		in NORMAL mode reindents the current paragraph.
" 		<C-F> and <tab>	in VISUAL mode reindent the highlighted block.
"
" ----------------------------------------------------------------------
" Requirements:	!^F must be present in the cinkeys options, if not, adapt!
" 		Hence, it works with C code with VIM 5.x, and with VIM 6.x
" 		for any text having an indenting strategy defined.
"
" Changes:	
" 		Ver 1.0 : first version
" 		Ver 1.1 : I discover '=' ... :-//
" 		Ver 1.1b: e-mail address obfuscated for spammers
"
" ========================================================================

if !exists("g:loaded_block_indent_vim")
  let g:loaded_block_indent_vim = 1

"  function! BI_()
"    exe "'<,'>v//normal i\<C-F>\<ESC>"
"  endfunction

  "vnoremap <C-F> :call BI_()<cr>
  "    vmap <tab>   <C-F>
  "    nmap <tab>   i<C-F><esc>
  "    nmap <C-tab> vip<C-F>
  
  vnoremap <C-F>   =$
  vnoremap <tab>   =
  nnoremap <tab>   =$
  nnoremap <C-tab> mzvip=`z
  
endif	" no reinclusion
