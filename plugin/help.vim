" ========================================================================
" VIM Macro for building help messages
"
" File:        help.vim
" Author:      Luc Hermitte <hermitte at free.fr>
"              <URL:http://hermitte.free.fr/vim/>
" Last update: 21st jul 2002
"
" ========================================================================
"
"
if !exists("g:loaded_Help_Vim")
  let g:loaded_Help_Vim = 1

" This function clear a previously built help message
function! ClearHelp(prefix)
  let varname = "g:" . a:prefix . "_help"
  exe "let ". varname . " = ''"
endfunction
"
" This function enables to build the help message
function! BuildHelp( prefix, newEntry )
  let varname = "g:" . a:prefix . "_help"
  exe "let e = exists(varname)"
  if !e
    exe "let ". varname . " = a:newEntry . '\n'"
  else
    exe "let " . varname . " = " . varname . ". a:newEntry . '\n'"
  endif
endfunction
"
" This function prints the help message
function! ShowHelp( prefix )
  let varname = "g:" . a:prefix . "_help"
  exe ":echo " . varname 
  echohl None
endfunction

"map <C-F1> :call ShowHelp("toto")<cr>

endif
