"=============================================================================
" File:         autoload/lh/Triggers.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      «s:license_type»
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      2.0.0
let s:k_version = 200
" Created:      08th Jun 2021
" Last Update:  08th Jun 2021
"------------------------------------------------------------------------
" Description:
"       Support functions for Triggers plugin
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
function! lh#Triggers#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#Triggers#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#Triggers#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API functions {{{1

" Function: lh#Triggers#TRIGGER(a, b) {{{2
" Doc: {{{3
" This little tool will enable to define switchable triggers that are
" neither mappings, settings nor abbreviations.
" When called, the function executes the command that should be in the first
" parameter and totally ignores the second parameter.
" The function lh#Triggers#_file() swap the two parameters of the TRIGGER command.
" The parameters must be separated by an unique comma -- or else update the
" pattern ! I only use it for echoings !
"
" Note:It is not designed to be used directly. Use instead the corresponding
" command : TRIGGER.
" Ex: TRIGGER "echo 'ON'", "echo 'OFF'"
" Attention: In order to work correctly, the double quotes must be around each
" parameter while the single ones are inside in order to protect the constant
" parameters of echo.
" }}}3
function! lh#Triggers#TRIGGER(a, b) abort
  exe a:a
endfunction

" Function: lh#Triggers#define(keys, action [, verbose]) {{{2
" Ex: lh#Triggers#define( '<F4>', 'set hlsearch' )
function! lh#Triggers#define(...) abort
  call s:Verbose('lh#Triggers#define(%1)', a:000)
  if (a:0 < 2) || (a:0 > 3)
    echohl ErrorMsg
    echo 'lh#Triggers#define(keys, action [,verbose] ) '.
          \      'incorrect number of arguments...'
    echohl None
    return
  endif
  let opp = lh#Triggers#_build_inv( a:2 )
  if opp == ""
    return
    "return a:2
  else
    call call('lh#Triggers#_do_switch', [a:1, a:2, opp] + a:000[2:])
  endif
endfunction

" Function: lh#Triggers#function(...) {{{2
" Doc: {{{3
" Set a switch mapping on "keys" that executes in turn "funcname"()
" then its opposite/negate. "funcname"() is defined in <"fileassoc">.
" This function search for Switched_"funcname"() in
" <$VIMRUNTIME/.triggers/"funcname".switch>. If the file does not
" exists, it is build thanks to lh#Triggers#_file().
" }}}3
function! lh#Triggers#function(...) abort
  call s:Verbose('lh#Triggers#function(%1)', a:000)
  if (a:0 < 3) || (a:0 > 5)
    echohl ErrorMsg
    echo "lh#Triggers#function(keys, funcname, fileassoc [,verbose [,execute]]) ".
          \      "incorrect number of arguments..."
    let p="(" | let i=1
    while i < a:0
      exe "let p .=  a:".i.".', '"
      let i +=  1
    endwhile
    echo p.")"
    echohl None
    return
  endif
  call lh#assert#value(a:1).not().empty("Keybinding expected as 1st parameter")
  call lh#assert#value(a:2).not().empty("Function name expected as 2nd parameter")
  call lh#assert#value(len(lh#command#matching_askvim('function', a:2.'('))).eq(1, 'Function name expected as 2nd parameter')
  call lh#assert#value(a:3).not().empty("File expected as 3rd parameter")
  call lh#assert#value(a:3).verifies('filereadable', [], "File expected as 3rd parameter")
  "1- Checks wheither the function has already been computed to its opposite
  "or not.
  let filename = lh#Triggers#_filename(a:2)
  ""if !filereadable( filename )
  " let g:p1 = a:3
  " let g:p2 = filename
  if !lh#path#is_up_to_date( a:3, filename )
    " Then build it !
    if lh#Triggers#rebuild_file( a:2, a:3 ) != ""
      echo "lh#Triggers#rebuild_file(".a:2.",".a:3.") failed."
      return
    endif
    echo filename . ' created...'
  else
    exe "so " . filename
  endif
  "2- Loads the opposite function ..
  "  .. embeded in lh#Triggers#rebuild_file()
  "3- Defines the switch
  let call1 = 'call ' . a:2 . '()'
  let call2 = 'call Switched_' . a:2 . '()'
  if a:0 == 4
    call lh#Triggers#_do_switch( a:1, call1, call2, a:4)
  elseif a:0 == 5
    call lh#Triggers#_do_switch( a:1, call1, call2, a:4, a:5)
  else
    call lh#Triggers#_do_switch( a:1, call1, call2)
  endif
  return 1
endfunction

" Function: lh#Triggers#rebuild_file(funcname, fileassoc) {{{2
function! lh#Triggers#rebuild_file(funcname, fileassoc) abort
  call s:Verbose('lh#Triggers#rebuild_file(%1, %2)', a:funcname, a:fileassoc)
  ""let this     = $VIMRUNTIME . '/macros/Triggers.vim'
  " -e -s => silent, no gvim
  let filename = lh#Triggers#_filename(a:funcname)
  " exe 'silent sp '.filename
  silent new
  " "1" required in lh#path#fix in order to work in win32-gvim lauched from
  " Windows-shell
  call lh#Triggers#_file(a:funcname, lh#path#fix(a:fileassoc,1), filename)
  if &verbose >=1 | call confirm('<'.filename.'> built', 'ok') | endif
endfunction

" Function: lh#Triggers#verbose(...) {{{2
function! lh#Triggers#v(...) abort
  return call('s:Verbose', a:000)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Function: lh#Triggers#_do_switch( keys, action, opposite [, verbose [,execute] ] ) {{{2
" Doc: {{{3
" Maps a sequence of "keys" to execute turn after turn "action" and its
" "opposite"
"
" I suppose that the NoVerbose is equivalent to the wish to see the
" "action" not executed. The verbose is really done only if the global
" variable g:loaded_vimrc is defined. Hence, do *not* forget to set it at
" the very end of your .vimrc.
" }}}3
function! lh#Triggers#_do_switch(...) abort
  call s:Verbose('lh#Triggers#_do_switch(%1)', a:000)
  if (a:0 < 3) || (a:0 > 5)
    echohl ErrorMsg
    echo "lh#Triggers#_do_switch(keys, action, opposite [,verbose [,execute] ] )? ".
          \      "incorrect number of arguments..."
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

  let cmd = {}
  let cmd.mode   = 'n'
  let cmd.nore   = 1
  let cmd.lhs    = a:1
  let cmd.silent = 1
  if l_exec == 1
    let cmd.rhs  = ':call lh#Triggers#_do_switch('.string(a:1).', '.string(a:3).', '.string(a:2). ', '.string(l_verb).', 1)<cr>'
    call s:Verbose('%1', a:2)
    if l_verb
      echo a:2
    endif
    exe a:2
  else
    " delay the execution
    let cmd.rhs  = ':call lh#Triggers#_do_switch('.string(a:1).', '.string(a:2).', '.string(a:3). ', '.string(l_verb).', 1)<cr>'
  endif
  " TODO: find a way to keep <leader> as <leader>, and don't it to anything
  " else, in particulary, don't change it in a space (when leader is space)
  " Unfortunatelly, in `:map µ :echo "<leader>a"`, the leader is changed!
  let cmd.rhs = substitute(cmd.rhs, "'<leader>", "mapleader.'", 'g')
  call lh#mapping#define(cmd)
endfunction
"---------------------------------------------------------------------------

" Function: lh#Triggers#_build_inv_4_set( action ) {{{2
" Builds the opposite action of the option assignment "action"
"
" The set format is the one accepted by vim, except that it authorizes white
" spaces after the affectation signs.
function! lh#Triggers#_build_inv_4_set( action ) abort
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
        let opp .=  ' ' . var . "!"
      elseif sign =~ "+="
        let opp .=  " ". var . "-=" . val
      elseif sign =~ "-="
        let opp .=  " ". var . "+=" . val
      else
        exe "let val2 = &" .var
        let opp .=  " ". var . "=" . val2
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
"---------------------------------------------------------------------------

" Function: lh#Triggers#_build_inv_4_map_n_abbr( action [,CheckOldValue]) {{{2
" Builds the opposite action of the Mapping or abbreviation : "action"
"
" If the format, we want at least 'map' or 'ab'
function! lh#Triggers#_build_inv_4_map_n_abbr(...) abort
  if (a:0==0) || (a:0>2)
    echohl ErrorMsg
    echo 'lh#Triggers#_build_inv_4_map_n_abbr(action [,CheckOldValue]) : Incorect number of arguments...'
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
"------------------------------------------------------------------------

" Function: lh#Triggers#_build_inv( action [, CheckOldValue] ) {{{2
" Doc: {{{3
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
" effective at the time the call to lh#Triggers#_build_inv() has been made ; not
" the one effective at the moment of the first switch.
" Ex: set tw=78 | call lh#Triggers#define('<F4>', 'set tw=120') | set tw=72
" If now we hit <F4>, &tw will equals 78. <F4> again, this time it equals
" 120, <F4> -> 78, etc. We have lost 72
" On an other hand, 'set tw+=40' works fine and 'set tw^=2' works strange
" because there no '/='.
"
" May be the functions could be extended to supports mechanisms like \def
" and \edef in TeX...
" }}}3
function! lh#Triggers#_build_inv(...) abort
  if (a:0==0) || (a:0>2)
    echohl ErrorMsg
    echo 'lh#Triggers#_build_inv(action [,CheckOldValue]) : Incorect number of arguments...'
    echohl None
    return
  endif
  if a:1 =~ '^\s*set\s\+'
    return lh#Triggers#_build_inv_4_set( a:1 )
  else
    if (a:0==2) && (a:2==0)
      return lh#Triggers#_build_inv_4_map_n_abbr( a:1, a:2 )
    else
      return lh#Triggers#_build_inv_4_map_n_abbr( a:1 )
    endif
  endif
endfunction
"---------------------------------------------------------------------------

" Function: lh#Triggers#_filename(funcname) {{{2
" Returns the filename of the file containing the switch function for
" <funcname>.
function! lh#Triggers#_filename(funcname) abort
  " call confirm('RT ='.$VIMRUNTIME, 'ok')
  " let path = matchstr(
  " \      lh#path#fix(&runtimepath,1),
  " \      substitute(lh#path#fix(expand('$HOME'),1), '\\', '.', 'g')
  " \         .'.\(vimfiles\|\.vim\)',
  " \    ) . '/.triggers/'
  let where =  lh#path#to_regex($HOME.'/').'\(vimfiles\|.vim\)'
  let path = lh#path#find(&rtp, where). '/.triggers/'
  " call confirm('pathv6 = '.path, 'ok')
  call lh#system#EnsurePath(lh#path#fix(path, 1))
  let path .= '/' . a:funcname . '.switch'
  return path
endfunction
"------------------------------------------------------------------------

" Function: lh#Triggers#_file(funcname, inputfilename, outputfilename) {{{2
" Doc: {{{3
" Builds the file containing all the opposite (undefinitions) macros of
" those defined in "funcname".
" Note: This macro should be apply while editing the file containing the
" function to transform.
" Called by: |lh#Triggers#function()|
" Assumes: no function embeded, no group, etc
" }}}3
function! lh#Triggers#_file(funcname, inputfilename, outputfilename) abort
  "0- Change some settings
  " Don't report changes for :substitute, there will be many of them.
  let cleanup = lh#on#exit()
        \.restore('&title')
        \.restore('&icon')
        \.restore('&report')
        \.restore('&magic')
        \.restore('@/')
        \.restore('&isk')
  set notitle noicon
  set report=1000000
  set magic
  set modifiable
  set isk&vim
  try
    " 1- Load a:inputfilename
    %delete _
    :exe '0r '.a:inputfilename

    "   disable folding
    normal! zn

    "2- Extract the function only
    call s:Verbose('%1', '0,/^\s*fu\%[nction]!\=\s*' . a:funcname . '\s*()/delete _')
    exe '0,/^\s*fu\%[nction]!\=\s*' . a:funcname . '\s*()/delete _'
    normal! gg
    call s:Verbose('%1', '/^\s*endf\%[function]/+1,$delete _')
    /^\s*endf\%[function]/+1,$delete _

    "3- Apply lh#Triggers#_do_switch() on all the corresponding lines
    let p_set   = '\%(set\)'
    let p_abbrv = '\([ic]\=\(nore\)\=ab\%[br]\=\)'
    let p_map   = '\(!\=[nvoic]\=\(nore\)\=map\)'
    let pattern = '^\s*\('.p_abbrv.'\|'.p_map.'\|'.p_set.'\)'
    exe 'g/'.pattern.'/ call setline(line("."),lh#Triggers#_build_inv(getline(line(".")), 0))'
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
    " Force fileformat to unix
    set ff=unix
    " save
    exe "silent w! " . a:outputfilename | bd

    "5- Restore old settings
  finally
    call cleanup.finalize()
  endtry
endfunction
"------------------------------------------------------------------------

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
