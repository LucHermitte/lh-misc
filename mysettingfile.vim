" ===========================================================================
" Vim File:	mysettingfile.vim
" Author: 	Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim>
" Last Update:	26th oct 2001
"
" Dependancies: buffoptions2.vim from Michael Geddes, updated by me
"
" Purpose:	Ease the loading and unloading of mappings regarding the
" 		filetype of the current buffer.
"
" Remark:	Using ReadFileTypeMap() from buffoptions.vim will a little
" 		bit slow down the opening of VIM on the first opening
"
" ===========================================================================

" Use the :SetAu user command to shorten the list below.
" If you get an error message "Command already exists", you already have
" defined the ":SetAu" command somewhere.  You should rename it.

" remove all previous settings
"au! Settings

" ---------------------------------------------------------------------------
" Quick loading for composing e-mails for instance
command -nargs=1  SetAuQuick au Syntax <args> so $VIMRUNTIME/settings/<args>.set

" ---------------------------------------------------------------------------
" Slower but buffer relative loadings
so $VIMRUNTIME/macros/buffoptions2.vim

" This function ensures we do not load "<a:type>.set" several times when
" editing several <a:type> files with "gvim *.vim *.tex" for instance.
"
" But I disabled it because of my intensive use of buffer-relative
" variables that should be defined each time. TODO: buffoptions.vim should
" recognize affectations like 'let \(b\|g\):.*=.*'.
function! LoadSettingsFile(type)
  " 1- checks if the settings file has allready been loaded
  let tt = 'g:SettingFileLoaded_'.a:type
  ""if !exists( tt )
    exe 'let '.tt.' = 1'
    " 2- load it!
    let ft = '$VIMRUNTIME/settings/'.a:type.'.set'
    " little trick in order to enable html mappings when editing php3 files
    " Cf. also php3.set
    if a:type=="html"
      call ReadFileTypeMap( "html,php3", ft )
    else 
      call ReadFileTypeMap( a:type, ft )
    endif
    " And the same for c & cpp ; don't forget java and C-like languages
    if a:type=="c"
      call ReadFileTypeMap( "c,cpp", ft )
    else 
      call ReadFileTypeMap( a:type, ft )
    endif
  ""endif
endfunction

" The command
command -nargs=1  SetAu  au Syntax <args> call LoadSettingsFile('<args>')

" ===========================================================================
" The autocommands.
SetAu		asx
SetAu		bib
SetAu		c
SetAu		cpp
SetAu		html
SetAu		java
SetAuQuick	mail
SetAu		pascal
SetAu		php3
SetAu		tex
SetAu		vim

" ===========================================================================
:delcommand SetAu
:delcommand SetAuQuick
