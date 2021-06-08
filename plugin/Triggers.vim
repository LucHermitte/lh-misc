" Rem: the v1.06 fixed a vim57 issue : Silent wasn't working correctly
"      the v1.08 fixed a vim6 issue : folded functions weren't parseable
"      the v1.09 fixed the directory name used to store the files.
"                      the filename resolution for win9x
"                FixDname() has been moved to another file.
"      the v1.10 added support for 'map <silent> ... ...'
"      the v1.11 has been updated to match the last version of FixDName()
"      the v1.12 uses normal! ; things changed into lh#Triggers#_file() in order to
"                have less possible errors.
"      the v1.13 attempt to not mess when recreating *.switch files.
"      the v1.14 simplifies a few things, and attempt to solve the error on
"                creation of the file on gvim-win32 launched from windows
"                shell. Will break with Vim 5.x that does not define :silent
"      the v1.15 relies less on system-tools.
"      the v1.16 relies on lh#path functions
"      the v1.17 relies on lh#path functions
"      the v1.18 Modernize parts of the code
"      the v2.00 have seen its functions moved to an autoload plugin
"===========================================================================
" Vim script file
"
" File:         Triggers.vim -- v2.00
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" Last Update:  08th Jun 2021
"
" Purpose:      Help to map a sequence of keys to activate and desactivate
"               either a mapping, a setting or an abbreviation.
"
" Remarks:      {{{
"  * You may have to customize lh#Triggers#_file(<funcname>) in regards of your
"    installation
"    }}}
" Examples:     {{{
"  * |call lh#Triggers#define( '<F7>', 'set ai' )
"    When pressing <F7> a first time, 'set ai!' is executed. Pressing <F7>
"    a second time executes 'set ai'. Of course, for sets, it is not really
"    interresting thanks to "map <F7> :set ai!<CR>"... I must admit that I
"    haven't seen any interrest (yet) in switching the numerical value of
"    settings, but it is handled ->
"  * |call lh#Triggers#define( '<F4>', 'set tw=120 sw^=2' )
"    ... works fine
"  * |call lh#Triggers#define( '<F9>', 'inoremap { {}<Left>' )
"    I'm sure you have allready seen an interrest in this one.
"  * |call lh#Triggers#define( '<F3>', 'iab LU Last Updated' )
"    Fine abbrev, but a little bit annoying when doing linear algebra...
"  * |source myAbbrevAndMap.vim
"    |call lh#Triggers#function('<F3>', 'MyAbbrevs', 'myAbbrevAndMap.vim' )
"    This one calls by turns MyAbbrevs(), and its undoing counterpart.
"    The undoing function does not exists ? No problem, its creates it
"    in the file "$VIMRUNTIME/.triggers/MyAbbrevs.vim" under VIM 5.x (or
"    "$HOME/.vim/.triggers/MyAbbrevs.vim" under VIM 6.x) and calls it
"    "Switched_MyAbbrevs()".
"    }}}
"
" Inspiration:  buffoptions.vim
" Deps:         fileuptodate.vim, and
"               (ensure_path.vim, fix_d_name.vim) or system_utils.vim
"
" TODO:         {{{
" (*) Support menus, setlocal, commands
" (*) Try to find a better $HOME than 'c:\' on Win 9x when VIM is run from the
"     file explorer...
" (*) Can't use <cr> in lh#Triggers#define(); e.g.:
"      call lh#Triggers#define( '<M-w>',
"       \ 'nnoremap <silent> <C-W> :call Window_CTRL_W()<cr>')
"     won't work.
" (*) Move functions to an autoload plugin
" }}}
"---------------------------------------------------------------------------
"}}}
"===========================================================================
"
"---------------------------------------------------------------------------
" Avoid reinclusion
if ! get(g:, 'force_reload_Triggers', 0) && exists('g:Triggers_loaded')
  finish
endif

let g:Triggers_loaded = 1
let cpop = &cpoptions
set cpoptions-=C

function! Trigger_Verbose(...) abort
  call lh#notify#deprecated('Trigger_Verbose', 'lh#Triggers#verbose')
  return call('lh#Triggers#verbose', a:000)
endfunction

" }}}

"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Function: TRIGGER(action, opposite)                           <internal>
" Command:  TRIGGER "action", "opposite"                        <exported>
" {{{
" {{{
" This little tool will enable to define switchable triggers that are
" neither mappins, settings nor abbreviations.
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
" }}}

command! TRIGGER call lh#Triggers#TRIGGER(<args>)
" }}}
"---------------------------------------------------------------------------
"---------------------------------------------------------------------------
" Function: Trigger_Define( keys, action [, verbose] )
"                                                               <exported> {{{
" Ex: Trigger_Define( '<F4>', 'set hlsearch' )
"
function! Trigger_Define( ... ) abort
  call lh#notify#deprecated('Trigger_Define', 'lh#Triggers#define')
  return call('lh#Triggers#define', a:000)
endfunction
" }}}
"---------------------------------------------------------------------------
" Function: Trigger_Function(keys, funcname, fileassoc [, verbose [,execute] ] )
"                                                               <exported> {{{
function! Trigger_Function(...) abort
  call lh#notify#deprecated('Trigger_Function', 'lh#Triggers#function')
  return call('lh#Triggers#function', a:000)
endfunction
"
" }}}
"---------------------------------------------------------------------------
" Avoid reinclusion
let &cpoptions = cpop
"===========================================================================
" vim600: set fdm=marker:
