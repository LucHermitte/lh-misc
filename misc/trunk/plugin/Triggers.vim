" Rem: the v1.06 fixed a vim57 issue : Silent wasn't working correctly
"      the v1.08 fixed a vim6 issue : folded functions weren't parseable
"      the v1.09 fixed the directory name used to store the files.
"                      the filename resolution for win9x
"                FixDname() has been moved to another file.
"      the v1.10 added support for 'map <silent> ... ...'
"      the v1.11 has been updated to match the last version of FixDName()
"      the v1.12 uses normal! ; things changed into Trigger_File() in order to
"                have less possible errors.
"      the v1.13 attempt to not mess when recreating *.switch files.
"      the v1.14 simplifies a few things, and attempt to solve the error on
"      		 creation of the file on gvim-win32 launched from windows
"      		 shell. Will break with Vim 5.x that does not define :silent
"===========================================================================
" Vim script file
"
" File:		Triggers.vim -- v1.14
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:	14th Jan 2006
"
" Purpose:	Help to map a sequence of keys to activate and desactivate
" 		either a mapping, a setting or an abbreviation.
"               
" Remarks:      {{{
"  * You may have to customize Trigger_File(<funcname>) in regards of your
"    installation
"    }}}
" Examples:     {{{
"  * |call Trigger_Define( '<F7>', 'set ai' )
"    When pressing <F7> a first time, 'set ai!' is executed. Pressing <F7>
"    a second time executes 'set ai'. Of course, for sets, it is not really
"    interresting thanks to "map <F7> :set ai!<CR>"... I must admit that I 
"    haven't seen any interrest (yet) in switching the numerical value of
"    settings, but it is handled ->
"  * |call Trigger_Define( '<F4>', 'set tw=120 sw^=2' ) 
"    ... works fine
"  * |call Trigger_Define( '<F9>', 'inoremap { {}<Left>' )
"    I'm sure you have allready seen an interrest in this one.
"  * |call Trigger_Define( '<F3>', 'iab LU Last Updated' )
"    Fine abbrev, but a little bit annoying when doing linear algebra...
"  * |source myAbbrevAndMap.vim
"    |call Trigger_Function('<F3>', 'MyAbbrevs', 'myAbbrevAndMap.vim' )
"    This one calls by turns MyAbbrevs(), and its undoing counterpart.
"    The undoing function does not exists ? No problem, its creates it
"    in the file "$VIMRUNTIME/.triggers/MyAbbrevs.vim" under VIM 5.x (or
"    "$HOME/.vim/.triggers/MyAbbrevs.vim" under VIM 6.x) and calls it
"    "Switched_MyAbbrevs()".
"    }}}
"
" Inspiration:	buffoptions.vim
" Deps:		fileuptodate.vim, and
" 		(ensure_path.vim, fix_d_name.vim) or system_utils.vim
"
" TODO:         {{{
" (*) Support menus, setlocal, commands
" (*) Try to find a better $HOME than 'c:\' on Win 9x when VIM is run from the
"     file explorer...
" (*) Can't use <cr> in Trigger_Define(); e.g.:
"      call Trigger_Define( '<M-w>', 
"  	\ 'nnoremap <silent> <C-W> :call Window_CTRL_W()<cr>')
"     won't work.
" }}}
"---------------------------------------------------------------------------
" Defines the following functions: {{{
" * Internal functions: [not for end user]
"  -> <i> function: Trigger_DoSwitch( key, action, opposite [, verbose] )
"  -> <i> function: Trigger_BuildInv4Set( action )
"  -> <i> function: Trigger_BuildInv4Map_n_Abbr( action [, CheckOldValue] )
"  -> <i> function: Trigger_BuildInv( action [, CheckOldValue] )
"  -> <i> function: Trigger_File(funcname)
"  -> <i> function: TRIGGER(action, opposite)
"  -> <i> function: Trigger_FileName(funcname)
" * "exported" functions: [yes! Use these ones]
"  -> <e> function: Trigger_Define( keys, action [, verbose] )
"  -> <e> function: Trigger_Function(keys, funcname, fileassociated)
"  -> <e> command:  TRIGGER "action", "opposite"
"  }}}
"===========================================================================
"
"---------------------------------------------------------------------------
" Avoid reinclusion
if exists('g:do_load_Triggers') || !exists('g:Triggers_loaded')
  let g:Triggers_loaded = 1
  let cpop = &cpoptions
  set cpoptions-=C
"
function! CheckDeps(func,file,path,or) " {{{
  if !exists(a:func)
    if version < 600
      if filereadable(a:path.'/'.a:file)
	exe 'so '.a:path.'/'.a:file
      elseif (''!=a:or) && filereadable(a:path.'/'.a:or)
	exe 'so '.a:path.'/'.a:or
      endif
    else
      exe 'runtime plugin/'.a:file.' macros/'.a:file.
	    \ ((''!=a:or) ? (' plugin/'.a:or.' macros/'.a:or) : '')
    endif
  endif
  if !exists(a:func)
    echohl ErrorMsg
    echo "<Triggers.vim> needs '".a:func."()' defined in <".a:file.">".
	    \ ((''!=a:or) ? ' or in <'.a:or.'>' : '')
    echo "   Please check for it on <http://hermitte.free.fr/vim/>\n"
    echohl None
    return 0
  endif
  return 1
endfunction
" }}}

let s_path = expand('<sfile:p:h>')
if !CheckDeps('*IsFileUpToDate', 'fileuptodate.vim', s_path,'')
      \ || !CheckDeps('*EnsurePath', 'ensure_path.vim', s_path,
      \               'system_utils.vim')
      \ || !CheckDeps('*FixPathName', 'fix_d_name.vim', s_path,
      \               'system_utils.vim')
  finish
endif

" }}}
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Function: TRIGGER(action, opposite)				<internal>
" Command:  TRIGGER "action", "opposite"			<exported>
" {{{
" {{{
" This little tool will enable to define switchable triggers that are
" neither mappins, settings nor abbreviations. 
" When called, the function executes the command that should be in the first
" parameter and totally ignores the second parameter. 
" The function Trigger_File() swap the two parameters of the TRIGGER command.
" The parameters must be separated by an unique comma -- or else update the 
" pattern ! I only use it for echoings !
"
" Note:It is not designed to be used directly. Use instead the corresponding 
" command : TRIGGER.
" Ex: TRIGGER "echo 'ON'", "echo 'OFF'"
" Attention: In order to work correctly, the double quotes must be around each 
" parameter while the single ones are inside in order to protect the constant 
" parameters of echo.
" }}}
function! TRIGGER(a, b)
  exe a:a
endfunction

command! TRIGGER call TRIGGER(<args>)
" }}}
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Function: Trigger_DoSwitch( keys, action, opposite [, verbose [,execute] ] )
" 								<internal> {{{
" {{{
" Maps a sequence of "keys" to execute turn after turn "action" and its
" "opposite"
" 
" I suppose that the NoVerbose is equivalent to the wish to see the
" "action" not executed. The verbose is really done only if the global
" variable g:loaded_vimrc is defined. Hence, do *not* forget to set it at
" the very end of your .vimrc.
" }}}
function! Trigger_DoSwitch( ... )
  if (a:0 < 3) || (a:0 > 5)
    echohl ErrorMsg
    echo "«Trigger_DoSwitch(keys, action, opposite [,verbose [,execute] ] )» ".
	  \	 "incorrect number of arguments..."
    echohl None
    return
  endif
  if a:0>=4     | let l_verb = a:4
    if a:0 >= 5 | let l_exec = a:5
    else        | let l_exec = l_verb
    endif
  else 
    let l_verb = 0 | let l_exec = 0
  endif

  let a1 = substitute( a:1, '<.\{-}>', '<c-v>\0', 1)
  let a2 = substitute( a:2, '<.\{-}>', '<c-v>\0', 2)
  let a3 = substitute( a:3, '<.\{-}>', '<c-v>\0', 3)
  if l_exec == 1
    exe "noremap ".a:1." :call Trigger_DoSwitch('".a1."','".
	  \	a3."','".a2."',".l_verb.",1)<CR>"
    exe a:2
    if (l_verb==1) && exists("g:loaded_vimrc") 
      echo a:2
    endif
  else
    " delay the execution
    exe "noremap ".a:1." :call Trigger_DoSwitch('".a1."','".
	  \	a2."','".a3."',".l_verb.",1)<CR>"
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_BuildInv4Set( action )			
" 								<internal> {{{
" {{{
" Builds the opposite action of the option assignment "action"
"
" The set format is the one accepted by vim, except that it authorizes white 
" spaces after the affectation signs.
" }}}
function! Trigger_BuildInv4Set( action )
  if a:action =~ '^\s*set\s\+'
    " purge <action> from the "set" string
    let sets = substitute( a:action, '^\s*set\s\+', '', '' )
    " extract all the options to set
    let opp = 'set'
    let pattern_set = '\s*\(\w\+\)\(\(\s*\(:\|[+^-]\==\)\s*\)\(\(\\ \|\w\)\+\)\)\=\s*\(.*\)$'
    while 1
      let var  = substitute( sets, pattern_set, '\1', '')
      let sign = substitute( sets, pattern_set, '\4', '')
      let val  = substitute( sets, pattern_set, '\5', '')
      let sets = substitute( sets, pattern_set, '\7', '')
      "echo var . sign . val . "-- " . sets
      if val == "" 
	let opp = opp . ' ' . var . "!"
      elseif sign =~ "+="
	let opp = opp . " ". var . "-=" . val
      elseif sign =~ "-="
	let opp = opp . " ". var . "-=" . val
      else
	exe "let val2 = &" .var 
	let opp = opp . " ". var . "=" . val2
      endif
      if sets == ""
	break
      endif
    endwhile
    return opp
  else
    echohl ErrorMsg
    echo "Incorect option definition : " . a:action
    echohl None
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_BuildInv4Map_n_Abbr( action [,CheckOldValue])	
" 								<internal> {{{
" {{{
" Builds the opposite action of the Mapping or abbreviation : "action"
"
" If the format, we want at least 'map' or 'ab'
" }}}
function! Trigger_BuildInv4Map_n_Abbr( ... )
  if (a:0==0) || (a:0>2)
    echohl ErrorMsg
    echo '«Trigger_BuildInv4Map_n_Abbr(action [,CheckOldValue])» : Incorect number of arguments...'
    echohl None
    return 
  endif
  let p_abbrv = '\([ic]\=\(nore\)\=ab\(br\)\=\)'
  let p_map   = '\(!\=[nvoic]\=\(nore\)\=map\)'
  let p_name  = '\s\+\(\(\\ \|\S\)\+\)'
  let p_buffer= '\%(\(\s\+<buffer>\)\|\s\+<silent>\)*'
  let pattern = '^\s*\('.p_abbrv.'\|'.p_map.'\)' . p_buffer.p_name . '\s\+.*$'
  if a:1 =~ '^\s*\(' . p_abbrv . '\|' . p_map . '\)\s\+'
    let cmd  = substitute( a:1, pattern, '\1', '' )
    let ctx  = matchstr( cmd, '^!\=[nvoic]\=' )
    let ctx  = matchstr( ctx, '[nvoic]\=' )
    let buf  = substitute( a:1, pattern, '\7', '' )
    let name = buf . substitute( a:1, pattern, '\8', '' )
    " let val  = substitute( a:1, pattern, '\10', '' )
    " echo '- '. ctx . ' - ' . cmd . ' - ' . name . ' - ' . val . ' -'
    " Map ----------------------------------------------------------------
    if cmd =~ p_map
      if (a:0==2)&&(a:2!=0)
	let rhs = maparg( name, ctx )
	if rhs != ""
	  " check for 'nore' feature -- equiv 16th char from map is '*'
	  " Message will be echo
	  redir @a | exe ctx . 'map '.name | redir END
	  if @a[16] == '*' | let opp = ctx . 'noremap ' .name . ' ' . rhs 
	  else             | let opp = ctx . 'map ' .name . ' ' . rhs 
	  endif
	else
	  let opp = ctx . 'unmap ' . name 
	endif
      else
	let opp = ctx . 'unmap ' . name 
      endif
      " Abbreviation -------------------------------------------------------
    elseif cmd =~ p_abbrv
      if (a:0==2)&&(a:2!=0)
	redir @a | exe ctx . 'abbr ' . name | redir END
	if @a =~ "No abbreviation found"
	  let opp = ctx . 'unabbr ' . name
	else
	  " first char matched is the nul char from @a
	  let val = substitute( @a, '.[ic]\s*\(\\ \|\S\)\+\s\+\*\=\(.*\)$','\2', '' )
	  let va0 = substitute( @a, '.[ic]\s*\(\(\\ \|\S\)\+\)\s\+\*\=\(.*\)$','\1', '' )
	  if va0 != name
	    echohl ErrorMsg
	    echo 'Abbreviation [' . name . '] inconsistant with a previous one [' . va0 . ']...'
	    echohl None
	    return 
	  endif
	  if @a[16] == '*' | let opp = ctx . 'noreabbr ' . name . ' ' . val
	  else             | let opp = ctx . 'abbr ' . name . ' ' . val
	  endif
	endif
      else
	let opp = ctx . 'unabbr ' . name
      endif
    endif
    return opp
  else
    echohl ErrorMsg
    echo "Incorect mapping/abbreviation definition : " . a:1
    echohl None
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_BuildInv( action [, CheckOldValue] )	
" 								<internal> {{{
" {{{
" Builds the opposite action for the Setting, Mapping or abbreviation :
" "action"
" 
" Rem.1: Setting CheckOldValue to something different to 0, prevent the
" function to checks for previous values of the switch mapping or
" abbreviation. The main purpose is to prevent the execution of "abbrv foo"
" or "map foo" which cause the display of unwanted messages. The main
" application comes when loading for the first time the new mapping. 
"
" Rem.2: CheckOldValue doesn't apply to "set" actions. Moreover, for hard
" settings of non boolean options, the value pushed is the one that were
" effective at the time the call to Trigger_BuildInv() has been made ; not
" the one effective at the moment of the first switch.
" Ex: set tw=78 | call Trigger_Define('<F4>', 'set tw=120') | set tw=72
" If now we hit <F4>, &tw will equals 78. <F4> again, this time it equals
" 120, <F4> -> 78, etc. We have lost 72
" On an other hand, 'set tw+=40' works fine and 'set tw^=2' works strange
" because there no '/='.
"
" May be the functions could be extended to supports mechanisms like \def
" and \edef in TeX...
" }}}
function! Trigger_BuildInv( ... )
  if (a:0==0) || (a:0>2)
    echohl ErrorMsg
    echo 'Trigger_BuildInv(action [,CheckOldValue]) : Incorect number of arguments...'
    echohl None
    return 
  endif
  if a:1 =~ '^\s*set\s\+'
    return Trigger_BuildInv4Set( a:1 )
  else
    if (a:0==2) && (a:2==0)
      return Trigger_BuildInv4Map_n_Abbr( a:1, a:2 )
    else
      return Trigger_BuildInv4Map_n_Abbr( a:1 )
    endif
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Function: Trigger_Define( keys, action [, verbose] )		
" 								<exported> {{{
" Ex: Trigger_Define( '<F4>', 'set hlsearch' )
"
function! Trigger_Define( ... )
  if (a:0 < 2) || (a:0 > 3)
    echohl ErrorMsg
    echo '«Trigger_Define(keys, action [,verbose] )» '.
	  \	 'incorrect number of arguments...'
    echohl None
    return 
  endif
  let opp = Trigger_BuildInv( a:2 )
  if opp == ""
    return 
    "return a:2
  else
    if a:0 == 2
      call Trigger_DoSwitch( a:1, a:2, opp )
    elseif a:0 == 3
      call Trigger_DoSwitch( a:1, a:2, opp, a:3 )
    endif
  endif
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_FileName(funcname)				
" 								<internal> {{{
" {{{
" Returns the filename of the file containing the switch function for
" <funcname>. }}}
function! Trigger_FileName(funcname)
  " call confirm('RT ='.$VIMRUNTIME, 'ok')
  if (version >= 600) " {{{
    let path = matchstr(
	  \      FixPathName(&runtimepath,1),
	  \      substitute(FixPathName(expand('$HOME'),1), '\\', '.', 'g')
	  \         .'.\(vimfiles\|\.vim\)',
	  \    ) . '/.triggers/'
    " call confirm('pathv6 = '.path, 'ok')
    call EnsurePath(path)
    " }}}
  else " VIM 5.x {{{
    let path = expand("$VIMRUNTIME") . "/.triggers/"
    call input('pathv5 = '.path)
    if 1 != EnsurePath(path) 
      let path = expand("$HOME") 
      if filereadable(path.'/.vim')
	let path = path . "/.vim/"
      elseif filereadable(path.'/vimfiles')
	let path = path . "/vimfiles/"
      else
	let path = path . "/vimfiles/"
      endif
      let path = path . '/.triggers/'
      " call input('pathv5bis = '.path)
      call EnsurePath(path)
    endif
    " }}}
  endif
  let path = path . a:funcname . '.switch'
  return path
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_File(funcname, filename)				
" 								<internal> {{{
" {{{
" Builds the file containing all the opposite (undefinitions) macros of
" those defined in "funcname".
" Note: This macro should be apply while editing the file containing the
" function to transform. 
" Called by: |Trigger_Function()|
" Assumes: no function embeded, no group, etc
" }}}
function! Trigger_File(funcname,inputfilename, outputfilename)
  "0- Change some settings
  " Don't report changes for :substitute, there will be many of them.
  let old_title = &title
  let old_icon = &icon
  let old_report = &report
  let old_search = @/
  let old_magic = &magic
  set notitle noicon
  set report=1000000
  set magic
  set modifiable

  " 1- Load a:inputfilename
  %delete _
  :exe '0r '.a:inputfilename
  
  "   disable folding 
  if version >= 600 | normal! zn 
  endif

  "2- Extract the function only
  exe '0,/^\s*fu\%[nction]!\=\s*' . a:funcname . '\s*()/delete _'
  normal! gg
  /^\s*endf\%[function]/+1,$delete _

  "3- Apply Trigger_DoSwitch() on all the corresponding lines 
  let p_set   = '\%(set\)'
  let p_abbrv = '\([ic]\=\(nore\)\=ab\%[br]\=\)'
  let p_map   = '\(!\=[nvoic]\=\(nore\)\=map\)'
  let pattern = '^\s*\('.p_abbrv.'\|'.p_map.'\|'.p_set.'\)'
  exe 'g/'.pattern.'/ call setline(line("."),Trigger_BuildInv(getline(line(".")), 0))'
  let p_trig  = '^\(\s*TRIGGER\s*\)\([^,]*\)\s*,\s*\([^,]*\)'
  " call append("$", "TRIGGER 1 , 2")
  " No warning about a pattern not found in :%s ; changed to silent!
  silent! exe '%s/'.p_trig.'/\1\3, \2/'
  " $delete _
  call append( "0", 'function! Switched_' . a:funcname . '()' )

  "4- And wq!
  " Reindent
  if (&indentexpr == 'GetVimIndent()') && exists('g:loaded_matchit')
    normal =%
  endif
  " change fileformat to unix
  set ff=unix
  " save
  exe "silent w! " . a:outputfilename | bd

  "5- Restore old settings
  let &report = old_report
  let &title = old_title
  let &icon = old_icon
  let &magic = old_magic
  let @/ = old_search
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_Function(keys, funcname, fileassoc [, verbose [,execute] ] )
" 								<exported> {{{
" {{{
" Set a switch mapping on "keys" that executes in turn "funcname"() 
" then its opposite/negate. "funcname"() is defined in <"fileassoc">.
" This function search for Switched_"funcname"() in
" <$VIMRUNTIME/.triggers/"funcname".switch>. If the file does not
" exists, it is build thanks to Trigger_File().
" }}}
function! Trigger_Function(...)
  if (a:0 < 3) || (a:0 > 5)
    echohl ErrorMsg
    echo "«Trigger_Function(keys, funcname, fileassoc [,verbose [,execute]])» ".
	  \	 "incorrect number of arguments..."
    let p="(" | let i=1
    while i < a:0
      exe "let p = p . a:".i.".', '"
      let i = i + 1
    endwhile
    echo p.")"
    echohl None
    return
  endif
  "1- Checks wheither the function has allready been computed to its opposite
  "or not.
  let filename = Trigger_FileName(a:2)
  ""if !filereadable( filename )
  if !IsFileUpToDate( a:3, filename )
    " Then build it !
    if Trigger_RebuildFile( a:2, a:3 ) != ""
      echo "Trigger_RebuildFile(".a:2.",".a:3.") failed."
      return
    endif 
    echo filename . ' created...'
  else
    exe "so " . filename
  endif
  "2- Loads the opposite function .. 
  "  .. embeded in Trigger_RebuildFile()
  "3- Defines the switch
  let call1 = 'call ' . a:2 . '()'
  let call2 = 'call Switched_' . a:2 . '()'
  if a:0 == 4
    call Trigger_DoSwitch( a:1, call1, call2, a:4)
  elseif a:0 == 5
    call Trigger_DoSwitch( a:1, call1, call2, a:4, a:5)
  else
    call Trigger_DoSwitch( a:1, call1, call2)
  endif
endfunction
"
" }}}
" let g:Triggers_this = expand("<sfile>:p")
"---------------------------------------------------------------------------
function! Trigger_RebuildFile(funcname, fileassoc) " {{{
  echo "executing: Trigger_RebuildFile(".a:funcname.",".a:fileassoc.")."
  ""let this     = $VIMRUNTIME . '/macros/Triggers.vim' 
  " -e -s => silent, no gvim
  let filename = Trigger_FileName(a:funcname)
  " exe 'silent sp '.filename
  silent new
  " "1" required in FixPathName in order to work in win32-gvim lauched from
  " Windows-shell
  call Trigger_File(a:funcname, FixPathName(a:fileassoc,1), filename)
  if &verbose >=1 | call confirm('<'.filename.'> built', 'ok') | endif
endfunction
" }}}
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Avoid reinclusion
let &cpoptions = cpop
endif
"===========================================================================
" vim600: set fdm=marker:
