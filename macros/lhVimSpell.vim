"=============================================================================
" File:		lhVimSpell.vim {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	0.6g
" Created:	One day in 2001
" Last Update:	14th Jul 2005
" Licence:	This is free software; see the GNU General Public Licence
"               version 2 or later for copying conditions.
"               There is NO warranty.
" }}}1
"------------------------------------------------------------------------
" Description:	Spellcheck plugin for VIM 6.x. {{{1
"               This plugin wraps call to ispell (/aspell) and have *many*
"               other features. cf. |VS_help.txt|
" }}}1
"------------------------------------------------------------------------
" Installation:	 {{{1
" The plugin is composed of several files. I suppose here that you have the
" end user version (otherwise, run make!) that contains:
"   - lhVimSpell.vim	: the main file of the plugin
"   - VS_gui-map.vim	: mappings for the corrector mode buffer
"   - a.vim		: an old version of Michael Sharpe's plugin
"   - ChangeLog		: changes history
"   - VS_help.txt	: the documentation of the plugin in VIM help format
"   - VS_help.html	: the same documentation but in HTML.
"
" I use the notation {rtp} as a shortcut to $HOME/.vim/ (for *NIX systems) or
" $HOME/vimfiles/ (for Ms-Windows systems) ; check ":help 'runtimepath'" for
" other systems.
"   - drop the documentation files into {rtp}/doc and execute (from VIM)
"     ':helptags $HOME/vimfiles/doc' once.
"   - If you want the plugin to be run systematically : drop the three vim
"     files into your {rtp}/plugin/ directory
"     Or, if you want the plugin to be run only in specific situations: drop
"     them into your {rtp}/macros/ directory, and source it whenever you need
"     it.
"     For instance, I execute ":runtime macros/lhVimSpell.vim" from my TeX
"     ftplugin.
"
" VS_gui-map.vim and lhVimSpell.vim *MUST* be in the same directory.
" For other dependencies aspects, check |VS_help.txt|
" 
" N.B.: there also exist my developper version of the plugin : lhVimSpell.vim
" is actually the concatenation of several thematic files. If you want to hack
" the plugin, it could be easier to check
"      <http://hermitte.free.fr/vim/ressources/vim-spell-dev.tar.gz>
" }}}1
" Inspiration:	VIMspell.vim by Claudio Fleiner <claudio {at} fleiner {dot} com>
" History:	cf. Changelog
" TODO:		cf. |VS_help.txt|
"=============================================================================
"
"------------------------------------------------------------------------
" Avoid reinclusion
if exists("g:loaded_lhVimSpell") && ! exists('g:force_reload_lhVimSpell')
  finish
endif
let g:loaded_lhVimSpell = 1

"=============================================================================
" Part:		lhVimSpell/dependencies {{{
" Last Update:	02nd Jul 2003
"------------------------------------------------------------------------
" Description:	Check for other non essential VIM plugins.
"------------------------------------------------------------------------
" TODO:		«missing features»
"=============================================================================
"

"------------------------------------------------------------------------
" Function: s:ErrorMsg(msg)                              {{{
" TODO: defines highlights for ErrorMsg and EchoMsg!
function! s:ErrorMsg(msg)
  if has('gui')
    call confirm(a:msg, '&Ok', 1, 'Error')
  else
    echohl ErrorMsg
    echo a:msg
    echohl None
  endif
endfunction
command! -nargs=1 VSgErrorMsg :call s:ErrorMsg(<args>)

function! s:EchoMsg(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction
command! -nargs=1 VSEchoMsg :call s:EchoMsg(<args>)
" }}}
"------------------------------------------------------------------------
if exists("*Trigger_DoSwitch")         " {{{
  command! -nargs=* IfTriggers <args>
else " silent comment
  command! -nargs=* IfTriggers silent :"<args>
endif
" }}}
"------------------------------------------------------------------------
if !exists("*FindOrCreateBuffer")      " {{{
  let ff = expand('<sfile>:p:h'). '/a-old.vim'
  let msg=''
  if filereadable(ff) | exe 'source '.ff
  else
    runtime macros/a-old.vim plugin/a-old.vim
  endif
  let msg = '<a-old.vim> is not visible from '.expand('<sfile>:p:h')."/\n"

  if !exists("*FindOrCreateBuffer")
    call s:ErrorMsg(msg.'Make sure <a-old.vim> correctly exports the function '.
	  \ 'FindOrCreateBuffer()')
  endif
endif
" }}}
"------------------------------------------------------------------------
if !exists("*FixPathName")             " {{{
  let ff = expand('<sfile>:p:h'). '/system_utils.vim'
  if filereadable(ff) | exe 'source '.ff
  else
    runtime macros/system_utils.vim plugin/system_utils.vim
  endif

  if !exists("*FixPathName")
    call s:ErrorMsg(
	  \ '<system_utils.vim> is not visible from '.expand('<sfile>:p:h'))
  endif
endif
" }}}
"------------------------------------------------------------------------

" Part:		lhVimSpell/dependencies }}}
"=============================================================================
" Part:		lhVimSpell/options {{{1
" Last Update:	05th Jul 2004
"------------------------------------------------------------------------
" Description:	Options for lhVimSpell
"------------------------------------------------------------------------
" Installation:	If you'd rather have other default values for the options, do
" the assignments into your .vimrc.
" TODO:		«missing features»
"=============================================================================

"=============================================================================
" Default values for the options       {{{2
"------------------------------------------------------------------------
" Function: s:Set_if_null(var, value)                    {{{3
function! s:Set_if_null(var, value)
  if (!exists(a:var)) | exe 'let '.a:var.' = '.a:value | endif
endfunction
command! -nargs=+ VSDefaultValue :call s:Set_if_null(<f-args>)
" }}}3
"------------------------------------------------------------------------
" Try to find aspell or ispell                           {{{3
" 
" If searchInRuntime.vim has been installed (check the original version on my
" web site -> http://hermitte.free.fr/vim/), then we check if aspell or ispell
" is visible from the $PATH.
" Otherwise, try to use `which' in a *nix shell ; or else suppose aspell.
"
if !exists('g:VS_spell_prog')
  if exists(':SearchInPATH')   " {{{4 searchInRuntime installed
    " Best and 100% portable way -- if searchInRuntime.vim is installed
    command! -nargs=1 VSSetProg :let g:VS_spell_prog=<q-args>
    :SearchInPATH VSSetProg aspell.exe ispell.exe aspell ispell 
    delcommand VSSetProg
  elseif &shell =~ 'sh'        " {{{4 Unix
    " `which' may exists on *nix systems
    let g:VS_spell_prog = matchstr(system('which aspell'), ".*\\ze\n")
    if g:VS_spell_prog !~ '.*aspell$'	" «aspell: Command not found»
      let g:VS_spell_prog = matchstr(system('which ispell'), ".*\\ze\n")
      if g:VS_spell_prog !~ '.*ispell$'	" «ispell: Command not found»
	unlet g:VS_spell_prog
      endif
    endif
  else                         " {{{4 Assume aspell
    " Assuming `aspell', but ... `aspell' may be invisible from the $PATH.
    let g:VS_spell_prog = 'aspell'
  endif
  " }}}4

  if exists('g:VS_spell_prog') " {{{4 found
    " As the exact path has been found, we split it.
    let s:ProgramPath   = fnamemodify(g:VS_spell_prog, ':p:h')
    let g:VS_spell_prog = fnamemodify(g:VS_spell_prog, ':t')
  else                         " {{{4 not found!!!
    call s:ErrorMsg('Please check your installation.'.
	  \ "\n".'lhVimSpell has not been able to find ispell or aspell.'.
	  \ "\n".'Update your $PATH or add into your .vimrc:'.
	  \ "\n".'      :let g:VS_spell_prog = "path/to/aspell_or_ispell/aspell"')
    let g:VS_spell_prog = 'aspell'
  endif
  "}}}4
endif
" }}}3
"------------------------------------------------------------------------
" Other options                                          {{{3
VSDefaultValue g:VS_stripaccents			0
VSDefaultValue g:VS_aspell_add_directly_to_dict		0

VSDefaultValue g:VS_jump_to_next_error_after_validation	1
VSDefaultValue g:VS_display_long_help			0
VSDefaultValue g:VS_parse_strings			1

" Some language options
VSDefaultValue g:VS_language_english			'american'
VSDefaultValue g:VS_language_when_ft_is_help		g:VS_language_english
VSDefaultValue g:VS_language_for_programming		g:VS_language_english

" Mappings
" Note: must be set before the plugin is loaded -> .vimrc
if exists('g:VS_map_leader')
  let s:map_leader = g:VS_map_leader
" elseif (has('win16') || has('win32') || has('dos16') || has('dos32') || has('os2')) && (&winaltkeys != 'no')
elseif has('winaltkeys') && (&winaltkeys != 'no') || !has('gui_running')
  let s:map_leader = '<Leader>s'
else
  let s:map_leader = '<M-s>'
endif

" Menus:
" Note: must be set before the plugin is loaded -> .vimrc
let s:menu_prio = exists('g:VS_menu_priority') 
      \ ? g:VS_menu_priority : 55
if s:menu_prio !~ '\.$' | let s:menu_prio = s:menu_prio . '.' | endif
let s:menu_name = exists('g:VS_menu_name')
      \ ? g:VS_menu_name     : 'Spell &check.'
if s:menu_name !~ '\.$' | let s:menu_name = s:menu_name . '.' | endif

delcommand VSDefaultValue


" :VSVerbose {num}
let s:verbose = 0
command! -nargs=1 VSVerbose let s:verbose=<args>


" }}}3
"------------------------------------------------------------------------
" }}}2
"=============================================================================
" Some accessors to the options        {{{2
"------------------------------------------------------------------------
command! -nargs=1 VSEcho :echo s:<args> 
"------------------------------------------------------------------------
" Function: s:Option(name, default [, scope])            {{{3
function! s:Option(name,default,...)
  let scope = (a:0 == 1) ? a:1 : 'bg'
  let name = 'VS_' . a:name
  let i = 0
  while i != strlen(scope)
    if exists(scope[i].':'.name) && (0 != strlen({scope[i]}:{name}))
      return {scope[i]}:{name}
    endif
    let i = i + 1
  endwhile 
  return a:default
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:Default_language()                         {{{3
function! s:Default_language()
  if s:Option('language','') != "" | return | endif
  if     v:lang =~? '^fr_FR\|^French'   | let g:VS_language = 'francais'
  elseif v:lang =~? '^uk_UK\|English'   | let g:VS_language = 'english'
  elseif v:lang =~? '^us_US\|American'  | let g:VS_language = 'american'
  elseif v:lang =~? '^de_DE'            | let g:VS_language = 'de'
  else 
    call s:ErrorMsg("The language v:lang=".v:lang." is not reconized. ".
	  \ "Assuming English.\n".
	  \ "Please check the functions s:Default_language() ".
	  \ "and s:Personal_dict()")
    " BTW: any comment is welcome on this topic
    let g:VS_language = 'english'
  endif
endfunction 
" }}}3
" Function: s:Language()                                 {{{3
function! s:Language()
  let lang = s:Option('language', '', 'wb')
  if '' != lang | return lang | endif

  let lang = s:Option('language_when_ft_is_'.&ft, '', 'g') 
  if '' != lang | return lang | endif

  let lang = s:Option('language_for_programming', '', 'g') 
  if ('' != lang) && s:IsAProgrammingLanguageFT(&ft) | return lang | endif
  
  call s:Default_language()
  return g:VS_language
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:AspellDirectories(which_directory)         {{{3
" Used by s:Personal_dict() only -> to directly modify the personal
" dictionary.
function! s:AspellDirectories(which_dir)
  if  !exists('s:AspellPersonalDirectory') 
    let config = system(s:I_call_iaspell(' config'))
    if '' == config
      VSgErrorMsg "Can't access to Aspell's configuration..."
      return ''
    endif
    let s:AspellConfigDirectory = 
	  \ matchstr(config,"conf-dir current:\\s*\\zs.\\{-}\\ze\n")
    if strlen(s:AspellConfigDirectory) == 0
      let s:AspellConfigDirectory = '/etc'
    endif
    let s:AspellDataDirectory = 
	  \ matchstr(config,"data-dir current:\\s*\\zs.\\{-}\\ze\n")
    if strlen(s:AspellDataDirectory) == 0
      let s:AspellDataDirectory = 'prefix:usr/lib/aspell-0.60'
    endif
    let s:AspellDictionaryDirectory = 
	  \ matchstr(config,"dict-dir current:\\s*\\zs.\\{-}\\ze\n")
    if strlen(s:AspellDictionaryDirectory) == 0
      let s:AspellDictionaryDirectory = '/usr/lib/aspell-0.60'
    endif
    let s:AspellPersonalDirectory = 
	  \ matchstr(config,"home-dir current:\\s*\\zs.\\{-}\\ze\n")
    if strlen(s:AspellPersonalDirectory) == 0
      let s:AspellPersonalDirectory = $HOME . '/.aspell'
    endif
    let s:AspellLocalDataDirectory = 
	  \ matchstr(config,"local-data-dir current:\\s*\\zs.\\{-}\\ze\n")
    if strlen(s:AspellLocalDataDirectory) == 0
      let s:AspellLocalDataDirectory = '/usr/lib/aspell-0.60/'
    endif
  endif
  if     a:which_dir =~ 'pers\%[onal]'   | return s:AspellPersonalDirectory
  elseif a:which_dir == 'data'           | return s:AspellDataDirectory
  elseif a:which_dir == 'localdata'      | return s:AspellLocalDataDirectory
  elseif a:which_dir =~ 'conf\%[ig]'     | return s:AspellConfigDirectory
  elseif a:which_dir =~ 'dict\%[ionary]' | return s:AspellDictionaryDirectory
  else
  endif
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:Personal_dict()                            {{{3
" Function to compute the path to the personal dictionary (for ASPELL only!)
" You may have to customize it to your own needs.
function! s:Personal_dict()
  let lang   = s:Language()
  let aspell = s:AspellDirectories('pers').'/'
  " version 0.60.x -> pers dicts have changed
  let aspell .= '.aspell.'
  if "" == lang
    :echoerr "The language option is not set.  "
	  \ "Please check the function s:Personal_dict()"
  elseif lang == "francais" | return aspell."fr.pws"
  elseif lang == "english"  | return aspell."english.pws"
  elseif lang == "american" | return aspell."english.pws"
  elseif lang == "de"       | return aspell."de.pws"
  else
    return aspell.lang.".pws"
  endif
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:CheckSpellLanguage()                       {{{3
function! s:CheckSpellLanguage()
  if !exists("b:spell_options") | let b:spell_options="" | endif
  return b:spell_options
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:AddMenuItem(mode,priority,title,key,action){{{3
function! s:AddMenuItem(mode,priority,title,key,action)
  exe a:mode.'menu <silent> '.s:menu_prio.a:priority.' '.
	\ escape(s:menu_name.a:title, '\ ').
	\ ((''!=a:key) ? '<tab>'. substitute(a:key, '&', '&&', 'g') : '').
	\ ' '. a:action
endfunction " }}}3
"------------------------------------------------------------------------
" }}}2

"=============================================================================
" Menus for the options                {{{2
"------------------------------------------------------------------------
let s:options_prio = s:menu_prio.'605.'
let s:options_name = s:menu_name.'&Options.'

"------------------------------------------------------------------------
" Function: s:AddMenuOption(priority, title, opt_name)   {{{3
function! s:AddMenuOption(priority,title,opt_name)
  exe 'amenu <silent> '.s:options_prio.a:priority.' '.
	\ escape(s:options_name.a:title, '\ ').'<tab>(=='.
	\ escape(s:Option(a:opt_name,-1, 'bg'), '.\').')'
	\ ' '. ':call <sid>ActMenu4_'.a:opt_name.'()<cr>'
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:DelMenuOption(priority, title, opt_name)   {{{3
function! s:DelMenuOption(priority,title,opt_name)
  exe 'aunmenu <silent> '.s:options_prio.a:priority.' '.
	\ escape(s:options_name.a:title, '\ ')
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:Show_Options_Menu()                        {{{3
function! s:Show_Options_Menu()
  :call s:AddMenuOption(10, 'Spell &checker', 'spell_prog')
  :call s:AddMenuOption(20, '&Strip accents', 'stripaccents')
  if g:VS_spell_prog =~ 'aspell'
    :call s:AddMenuOption(30, '&Add directly to dictionary', 
	  \ 'aspell_add_directly_to_dict')
  endif
  :call s:AddMenuOption(40, '&Jump to next error after validation', 
	\ 'jump_to_next_error_after_validation')

endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:ActMenu4_spell_prog()                    {{{3
function! s:ActMenu4_spell_prog()
  let which = confirm('Which spellchecker do you want to use ?',
	\ "&Aspell\n&Ispell\nAn&other\n&Cancel", 1)
  if     1 == which | let spell_prog = 'aspell'
  elseif 2 == which | let spell_prog = 'ispell'
  elseif 3 == which | let spell_prog = ''
  elseif 4 == which | return
  endif
  if 3 != which 
    if s:verbose >= 1
      call confirm('Executing: "'.spell_prog.'-v"', '&Ok', 1)
    endif
    if (system(spell_prog. '-v') !~? 'version') || (v:shell_error != 0)
      call s:ErrorMsg("Can not find «".spell_prog."»\n")
      let spell_prog = ''
    endif
  endif 

  if spell_prog == ''
    let spell_prog = inputdialog('Path to your spell-checker: ')
  endif

  if spell_prog != ''
    let g:VS_spell_prog = spell_prog
  endif

  :call s:DelMenuOption(10, 'Spell &checker', 'spell_prog')
  :call s:AddMenuOption(10, 'Spell &checker', 'spell_prog')

  if (spell_prog !~ 'aspell') && (g:VS_aspell_add_directly_to_dict>=0)
    let g:VS_aspell_add_directly_to_dict = -1 - 
	  \ g:VS_aspell_add_directly_to_dict
    :call s:DelMenuOption(30, '&Add directly to dictionary', 
	  \ 'aspell_add_directly_to_dict')
  else
    let g:VS_aspell_add_directly_to_dict = g:VS_aspell_add_directly_to_dict - 1
    :call s:AddMenuOption(30, '&Add directly to dictionary', 
	  \ 'aspell_add_directly_to_dict')
  endif
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:ActMenu4_stripaccents()                    {{{3
function! s:ActMenu4_stripaccents()
  let g:VS_stripaccents = 1 - g:VS_stripaccents
  :call s:DelMenuOption(20, '&Strip accents', 'stripaccents')
  :call s:AddMenuOption(20, '&Strip accents', 'stripaccents')
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:ActMenu4_aspell_add_directly_to_dict()     {{{3
function! s:ActMenu4_aspell_add_directly_to_dict()
  let g:VS_aspell_add_directly_to_dict = 1 - g:VS_aspell_add_directly_to_dict
  :call s:DelMenuOption(30, '&Add directly to dictionary', 
	\ 'aspell_add_directly_to_dict')
  :call s:AddMenuOption(30, '&Add directly to dictionary', 
	\ 'aspell_add_directly_to_dict')
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:ActMenu4_jump_to_next_error_after_validation(){{{3
function! s:ActMenu4_jump_to_next_error_after_validation()
  let g:VS_jump_to_next_error_after_validation = 
	\ 1 - g:VS_jump_to_next_error_after_validation
  :call s:DelMenuOption(40, '&Jump to next error after validation', 
	\ 'jump_to_next_error_after_validation')
  :call s:AddMenuOption(40, '&Jump to next error after validation', 
	\ 'jump_to_next_error_after_validation')
endfunction " }}}3
"------------------------------------------------------------------------
" }}}2

" Part:		lhVimSpell/options}}}1
"=============================================================================
" Part:		lhVimSpell/corrected buffer functions {{{1
" Last Update:	26th Sep 2003
"------------------------------------------------------------------------
" Description:	Defines the mappings and menus for the spell-checked buffer.
"------------------------------------------------------------------------
" TODO:		«missing features»
"=============================================================================

"===========================================================================
" Macros    {{{2
"===========================================================================
  IfTriggers
	\ noremap !VS_swapL!	:call Trigger_DoSwitch('!VS_swapL!', 
			\ 'let b:VS_language="american"', 
			\ 'let b:VS_language="'.<sid>Language().'"', 1, 1)<cr>
" }}}2
"===========================================================================
" Functions {{{2
" ========================================================================
function! s:Maps_4_file_edited()                         " {{{3
  if !hasmapto('<Plug>VS_check', 'n')
    nmap <buffer> <F4>					<Plug>VS_check
    exe 'nmap <buffer> '.s:map_leader.'r		<Plug>VS_check'
  endif
  nnoremap <silent> <buffer> <Plug>VS_check	
	\ :update<cr>:call <sid>M_Parse_current_file()<cr>
  if !hasmapto('<Plug>VS_check', 'v')
    vmap <buffer> <F4>					<Plug>VS_check
    exe 'vmap <buffer> '.s:map_leader.'r		<Plug>VS_check'
  endif
  vnoremap <silent> <buffer> <Plug>VS_check	
	\ :call <sid>M_Parse_region()<cr>

  if !hasmapto('<Plug>VS_showE', 'n')
    exe 'nmap <buffer> '.s:map_leader.'s		<Plug>VS_showE'
  endif
  nnoremap <silent> <buffer> <Plug>VS_showE
	\ :call <sid>Show_errors()<cr>

  if !hasmapto('<Plug>VS_add', 'n')
    exe 'nmap <silent> <buffer> '.s:map_leader.'*	<Plug>VS_add'
  endif
  nnoremap <silent> <buffer> <Plug>VS_add
	\ :call <sid>M_AddWord(<sid>Current_Word(),0)<cr>

  if !hasmapto('<Plug>VS_add_low', 'n')
    exe 'nmap <silent> <buffer> '.s:map_leader.'&	<Plug>VS_add_low'
  endif
  nnoremap <silent> <buffer> <Plug>VS_add_low
	\ :call <sid>M_AddWord(<sid>Current_Word(),1)<cr>

  if !hasmapto('<Plug>VS_ignore', 'n')
    exe 'nmap <silent> <buffer> '.s:map_leader.'i	<Plug>VS_ignore'
  endif
  nnoremap <silent> <buffer> <Plug>VS_ignore
	\ :call <sid>M_IgnoreWord(<sid>Current_Word())<cr>

  if !hasmapto('<Plug>VS_alt', 'n')
    nmap <buffer> <S-F4>				<Plug>VS_alt
    exe 'nmap <silent> <buffer> '.s:map_leader.'a	<Plug>VS_alt'
    exe 'nmap <silent> <buffer> '.s:map_leader.'<tab>	<Plug>VS_alt'
  endif
  nnoremap <silent> <buffer> <Plug>VS_alt
	\ :call <sid>G_Launch_Corrector()<cr>

  " IfTriggers nmap <buffer> <C-F4>			!VS_swapL!
  IfTriggers exe 'nmap <buffer> '.s:map_leader.'L	!VS_swapL!'

  if !hasmapto('<Plug>VS_exit', 'n')
    " nmap <buffer> g=					<Plug>VS_exit
    exe 'nmap <buffer> '.s:map_leader.'E		<Plug>VS_exit'
  endif
  nnoremap <silent> <buffer> <Plug>VS_exit
	\ :call <sid>ExitSpell()<CR>


  if !hasmapto('<Plug>VS_nextE', 'n')
    nmap <buffer> <M-n>					<Plug>VS_nextE
    exe 'nmap <buffer> '.s:map_leader.'n		<Plug>VS_nextE'
  endif
  nnoremap <silent> <buffer> <Plug>VS_nextE
	\ :call <sid>SpchkNext()<cr>

  if !hasmapto('<Plug>VS_prevE', 'n')
    nmap <buffer> <M-p>					<Plug>VS_prevE
    exe 'nmap <buffer> '.s:map_leader.'N		<Plug>VS_prevE'
    exe 'nmap <buffer> '.s:map_leader.'p		<Plug>VS_prevE'
  endif
  nnoremap <silent> <buffer> <Plug>VS_prevE
	\ :call <sid>SpchkPrev()<cr>

  if !hasmapto('<Plug>VS_help', 'n')
    nmap <buffer> <M-s>h				<Plug>VS_help
    exe 'nmap <buffer> '.s:map_leader.'h		<Plug>VS_help'
  endif
  nnoremap <silent> <buffer> <Plug>VS_help
	\ :h lhVimSpell<cr>
endfunction " }}}3
"------------------------------------------------------------------------
function! s:Global_menus()                               " {{{3
  " Menus
  if has('gui_running') && has('menu')
    " let s:menu_start= 'nmenu <silent>'.s:menu_prio.'.100 '.s:menu_name

    call s:AddMenuItem('n', 100, '&Run spell checker', s:map_leader.'r', '<Plug>VS_check')
    call s:AddMenuItem('v', 100, '&Run spell checker', s:map_leader.'r', '<Plug>VS_check')
    call s:AddMenuItem('n', 100, '&Show misspellings',  s:map_leader.'s', '<Plug>VS_showE')
    call s:AddMenuItem('n', 100, 'Show &alternatives', s:map_leader.'a', '<Plug>VS_alt')
    call s:AddMenuItem('n', 100, 'E&xit',              s:map_leader.'E', 'call <sid>ExitSpell()<CR>')
    " TODO: disable/enable menu->exit according to the current mode
    exe 'menu disable '.escape(s:menu_name.'Exit', ' \')
    call s:AddMenuItem('a', 200, '-3-', '', '<nop>')
    call s:AddMenuItem('n', 200, 'Add to &dictionary', s:map_leader.'*', '<Plug>VS_add')
    call s:AddMenuItem('n', 200, 'Idem low&case',      s:map_leader.'&', '<Plug>VS_add_low')
    call s:AddMenuItem('n', 200, '&Ignore word',       s:map_leader.'i', '<Plug>VS_ignore')

    IfTriggers 
	  \ call s:AddMenuItem('a', 100, '-1-', '', '<nop>')
    IfTriggers 
	  \ call s:AddMenuItem('n', 100, 'Change &Language', s:map_leader.'L', '!VS_swapL!')

    call s:AddMenuItem('a', 510, '-2-', '', '<nop>')
    call s:AddMenuItem('n', 510, '&Next misspelling', s:map_leader.'n', '<Plug>VS_nextE')
    call s:AddMenuItem('n', 510, '&Prev misspelling', s:map_leader.'p', '<Plug>VS_prevE')

    call s:AddMenuItem('a', 600, '-4-', '', '<nop>')
    call s:AddMenuItem('n', 610, '&Help', s:map_leader.'h', '<Plug>VS_help')
  endif
endfunction " }}}3
"------------------------------------------------------------------------
" Define the maps when buffers are loaded                {{{3
function! s:CheckMapsLoaded(force)
  if (expand('%') !~ 'spell-corrector') &&
	\ (!exists('b:VS_map_loaded') || (1 == a:force))
    let b:VS_map_loaded = 1
    silent call s:Maps_4_file_edited()
  endif
endfunction

call s:CheckMapsLoaded(1)
call s:Global_menus()
call s:Show_Options_Menu()

augroup VS_maps
  au!
  au  BufNewFile,BufReadPost * :call s:CheckMapsLoaded(0)
augroup END
" }}}3
" }}}2

" Part:		lhVimSpell/corrected buffer functions }}}1
"=============================================================================
" Part:		lhVimSpell/interface to [ia]spell {{{
" Last Update:	26th Sep 2003
"------------------------------------------------------------------------
" Description:	Interface functions to external spell-checkers like [ia]spell
"------------------------------------------------------------------------
" TODO:		
"=============================================================================
"

"===========================================================================
" Programs calls                       {{{
"------------------------------------------------------------------------
" Function: s:I_mode(ext,ft) : string                    {{{
function! s:I_mode(type)
  " 100% Aspell options {{{
  " if     a:type =~ 'tex\|sty'            | let mode = ' --mode='. a:type 
  " elseif a:type =~ 'htm\|xml\|php\|incl' | let mode = ' --mode=sgml'
  " else                                   | let mode = ''
  " endif
  " }}}

  " Aspell and Ispell compatible options {{{
  " If updates done, check s:IsAProgrammingLanguageFT in VS_fm-fun.vim
  if     a:type =~ 'tex\|sty\|dtx\|ltx'                   | let mode = ' -t'
  elseif a:type =~ 'htm\|php\|incl'                       | let mode = ' -H'
  elseif a:type =~ 'xml\|xsl\|sgm\|docbk'                 | let mode = ' --mode=sgml'
  elseif a:type =~ 'nroff' && g:VS_spell_prog =~ 'ispell' | let mode = ' -n'
  elseif a:type =~ 'mail'  && g:VS_spell_prog =~ 'aspell' | let mode = ' -e'
  else                                                    | let mode = ''
  endif
  return mode . ' '
  " }}}
endfunction
" }}}
"------------------------------------------------------------------------
" Function s:I_list_option() : -l/--list                   {{{
function! s:I_list_option()
  if     g:VS_spell_prog =~ 'ispell' | return '-l'
  elseif g:VS_spell_prog =~ 'aspell' | return '--list'
  else   throw "lhVimSpell: cannot determine the name of the --list option"
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:I_call_iaspell([parameter for ia-spell])     {{{
function! s:I_call_iaspell(...)
  let arg = (a:0 == 1) ? a:1 : ''
  return g:VS_spell_prog . ' -d ' . s:Language() . ' '. s:Option('iaspell_options', ''). arg . ' '
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:I_pipe_to_iaspell(filename)                  {{{
function! s:I_pipe_to_iaspell(filename)
  " let cmd = SysCat(a:filename) . ' | ' . s:I_call_iaspell(' -a')
  let cmd = s:I_call_iaspell(' -a ') . ' < ' . FixPathName(a:filename)
  if s:Option('stripaccents', 0, 'g')
    let cmd = cmd . " --strip-accents " 
  endif
  if s:verbose >= 1
    call confirm('Executing: '.cmd, '&Ok', 1)
    if !exists('g:VS_cmd')
      let g:VS_cmd = []
    endif
    call add(g:VS_cmd, cmd)
  endif
  return system(cmd)
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================
" List errors                          {{{
"------------------------------------------------------------------------
" Function: s:I_list_errors(filename, filetype_if_known) : string
" Retrieve the list (string) of misspellings
" Note: It even work on MsDos/Windows system, but it is slower if no Unix
" layer (like Cygwin or UnixUtils) has been installed.
function! s:I_list_errors(filename,ft)
  " type <- filetype (if given) or file-extension
  let type = (a:ft!="") ? a:ft : matchstr(a:filename, '[^.]\{-}$')
  " Fix the filename path according to the current shell.
  let filename = FixPathName(a:filename)
  " Check which `sort' will be used
  let msdos = (SystemDetected() == 'msdos') && !UnixLayerInstalled()
  let sort = !msdos ? ' | '.SysSort('-u') : ''
  let cmd = s:I_call_iaspell(s:I_mode(type)).s:I_list_option().' < '.filename.sort
  if s:verbose > 0
    call confirm('calling: '.cmd, '&Ok', 1)
    if !exists('g:VS_cmd')
      let g:VS_cmd = []
    endif
    call add(g:VS_cmd, cmd)
  endif
  let res  = system(cmd)
  if msdos
    " Special case: on a pure msdos/windows box, `SORT.EXE' is not suitable,
    " hence we emule it as well as `uniq'
    :silent new
    :silent 0put=res
    :Sort
    :Uniq
    let save_a = @a
    :silent %yank a
    let res = @a
    let @a = save_a
    :silent bw!
  endif

  " Return the sorted list of misspellings
  if s:verbose > 0
    call confirm('misspellings found: '.substitute(res, "\r\\|\n", ' ; ', 'g'),
	  \ '&Ok', 1)
  endif
  return res
endfunction
" }}}
"===========================================================================
" Get alternatives                     {{{
"------------------------------------------------------------------------
" Fill a temporary file with the alternative for every misspellings (a:error)
" If fail    : nothing done, empty string returned
" If success : string returned == name of the temporary file for which a
"              buffer is stil open.
function! s:I_get_alternatives(errors)
  let lang = s:Language()
  " filename of a temporary file
  let tmp = tempname()
  
  " split open a new buffer
  silent exe 'split ' . tmp
  " write the list of misspellings to the buffer
  silent 0put = a:errors
  " purge empty lines
  silent g/^$/d _
  " write the result and then clear the buffer
  silent w | silent %delete _
  " if the file is empty => abort !
  if 0 == getfsize(tmp) 
    silent bw!
    call delete(tmp)
    return ''
  endif
  " execute aspell, the result is inserted in the current tmp buffer
  let b:VS_language = lang
  let alts = s:I_pipe_to_iaspell(tmp)
  silent 0put=alts
  " delete empty lines
  silent g/^$/d _
  " delete '^*$'
  silent g/\*/d _
  " write
  silent w
  " return the file name
  return tmp
endfunction
" }}}
"===========================================================================
" Maintenance                          {{{
"------------------------------------------------------------------------
" Function: s:I_aspell_directly_to_dict(word, lowcase)   {{{
function! s:I_aspell_directly_to_dict(word,lowcase)
  " 1- Check we are using Aspell
  if (g:VS_spell_prog !~ '.*aspell\(\.exe\)\=$')
    call s:ErrorMsg("Can not add «".a:word."» directly into the dictionary.\n"
	  \       . "\nThis option is only available with aspell.\n")
    return 0
  endif
  " 2- Add it
  " 2.a/ Open the ASPELL local-dictionary
  silent exe 'split '.s:Personal_dict() 
  " 2.b/ Increment the number of word
  silent exe "normal! $\<c-a>"
  " 2.c/ Add the word to the last line
  silent $put=a:word
  " 2.d/ chage it to lower case if required
  if a:lowcase == 1 | silent normal! guu 
  endif
  " 2.e/ save and close
  silent w | silent bw
  return 1
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:I_add_word_to_dict(word, lowcase)          {{{
" If the word to add contains accents, the function offer the choice to
" directly add the word to the dictionary, without using ASPELL. 
" Reason : aspell (under windows/MinGW-build only ?) is not able to add
" accentuated words to the dictionary. Hence, I've chosen to add this kind
" of words directly in the dictionary file.
function! s:I_add_word_to_dict(word,lowcase)
  if (g:VS_spell_prog=~'.*aspell\(\.exe\)\=') 
    if (g:VS_aspell_add_directly_to_dict == 1) 
      " always add directly to dictionary
      if s:verbose >= 1
	call confirm("``".a:word."'' is beeing directly added to aspell's ".
	      \ "personal dictionary'", '&Ok', 1)
      endif
      return s:I_aspell_directly_to_dict(a:word, a:lowcase)
    elseif match(a:word, "[^A-Za-z']") != -1 
      " accentuated word
      let c = confirm("The word «".a:word."» contains accentuated characters.\n"
	    \ . "Are you sure you want to add it to the dictionary ?",
	    \ "&Yes\n&Abort", 1, "Warning")
      if c == 1 
	return s:I_aspell_directly_to_dict(a:word, a:lowcase)
      endif
      return 0
    endif
  endif
  "
  " Otherwise: Classical method
  let cmd = (a:lowcase == 1) ? '&' : '*'
  let cmd = cmd . a:word 
  " Save the dictionary
  let cmd = cmd . "\n#"
  let tmp = tempname()
  silent exe "split ".tmp
  silent 0put=cmd
  silent w | silent bw
  if s:verbose >= 2
    call confirm("Passing to iapsell:\n".cmd, '&Ok', 1)
  endif
  call s:I_pipe_to_iaspell(tmp)
  call delete(tmp)
  return 1
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================

" Part:		lhVimSpell/interface to [ia]spell }}}
"=============================================================================
" Part:		lhVimSpell/prog. languages functions {{{1
" Last Update:	14th Jul 2005
"------------------------------------------------------------------------
" Description:	Functions that extract text from comments
"------------------------------------------------------------------------
" Note:		Requires Vim 6.2 at least & searchInRuntime
" TODO:		«missing features»
"=============================================================================



"=============================================================================
" Function: s:SynList(name) : string                     {{{
function! s:SynList(name)
  let a_save = @a
  redir @a
    exe 'silent! syn list '.a:name
  redir END
  let res = @a
  let @a = a_save
  return res
endfunction
" }}}

" Function: s:AddZsZe(expr, zs)                          {{{
function! s:AddZs(expr,zs)
  " Edge case
  if a:zs == 0 | return '\zs'.a:expr | endif
  
  " Suppose there is no '*' or '\+' in the first characters.
  
  let p2 = a:expr
  " length of \d -> one
  let p2 = substitute(p2, '\\\@<!\(\%(\\\\\)*\)\d', '\11', 'g')
  " length of \1, \2, ..., \9 is undetermined -> @
  let p2 = substitute(p2, '\\\@<!\\\(\%(\\\\\)*\)\d', '\109', 'g')
  " -> 4\\5\\\\\653 -> 1\\1\\\\0911

  " Nothing between square brackets counts
  let brackets = matchstr(p2, '\[.\{-}\]')
  while '' != brackets
    let br = substitute(brackets, '.', '0', 'g')
    let br = substitute(br, '\(.*\).', '\11', '')
    let p2 = substitute(p2, '\[.\{-}\]', br, '')
    let brackets = matchstr(p2, '\[.\{-}\]')
  endwhile

  " Some special escaped characters count 0
  let p2 = substitute(p2, '\\[<+=>|_(){}[?]=\|[$^]', '00', 'g')
  " Other escaped characters count '01'
  let p2 = substitute(p2, '\\.', '01', 'g')

  " Other characters count 1
  let p2 = substitute(p2, '[^0-9]', '1', 'g')

  " Loop: count up to a:zs: the actual number of printable characters in
  " a:expr
  let c = 0 | let i = 0
  while (c < a:zs) && (i < strlen(p2))
    if s:verbose >= 2
      call confirm( substitute(a:expr, '.\{'.(i+1).'}', '\0 >'.p2[i].'<', '')
	    \ ."\nc = ".c
	    \ , '&ok', 1)
    endif
    if p2[i] == 9
      VSgErrorMsg 'Not able to correctly deduce the emplacement for "\zs" in: '.a:expr.'   ms=s+'.a:zs
      return a:expr
    endif
    let c = c + p2[i]
    let i = i + 1
  endwhile
  if 0
    return substitute(a:expr, '.\{'.i.'}', '\0\\zs', '')
  else
    return substitute(a:expr, '.\{'.i.'}', '\\%(\0\\)\\@<=', '')
  endif
endfunction
" }}}

" Function: s:SynGroupPattern(ft, type, apply_ms_me)     {{{
function! s:SynGroupPattern(ft, type, apply_ms_me,...)
  " Todo: support \M, \v and \V ; \c and \C
  " Args: typical {type} for us -> "Comment" and "String"
  "       {...} : number of the first group (kinda of offset)
  let total_number_of_groups = ((a:0>0) && (a:1!='')) ? a:1 : 0

  " Get list of :syn items
  let list = s:SynList(a:ft.a:type)

  " Build the pattern in a loop
  let pattern =''
  while list != ''
    " 1- If a :syn-match {{{
    let line = matchstr(list, "^[^\r\n]".'*match\s\+\zs\(.\).\{-}\1\S*')
    if line != ''
      let pat = matchstr(line, '\(.\)\zs.\{-}\ze\1')
      let zs  = matchstr(line, 'ms=s+\zs\d\+\ze')
      " :syn-match }}}
    elseif list =~ "^[^\r\n]".'*start' " 2- If a :syn-region {{{
      let start    = matchstr(list, 'start=\(.\)\zs.\{-}\ze\1\S*')
      let zs       = matchstr(list, 'start=\(.\).\{-}\1\S*ms=s+\zs\d\+\ze')
      let end      = matchstr(list, 'end=\(.\)\zs.\{-}\ze\1\S*')
      let skip     = matchstr(list, 'skip=\(.\)\zs.\{-}\ze\1\(\s\|$\)')
      let any_char = (list =~ '^.*oneline') ? '.' : '\_.'
      if skip != ''
	let  middle = '\%(\%('.skip.'\)\|'.any_char.'\)\{-}'
      else
	let  middle = any_char.'\{-}'
      endif
      let pat = start . middle . end
      if s:verbose >= 1
	call confirm(
	      \ 'start ='.start."\n".'end   ='.end."\n".'skip  ='.skip."\n".'anychar='.any_char."\n".
	      \ 'middle='.middle."\n".'pat   ='.pat."\n"
	      \ , '&Ok', 1)
      endif
      " }}}
    endif
    if exists('pat') && (pat != '')
      " Renumber groups {{{
      " Check for '\(...\)' and '\z(...\)' (internal and external groups)
      let ext_i = 0 | let int_i = 0
      let pat_pos = match(pat, '\\z\=(.\{-}\\)')
      while pat_pos != -1
	let total_number_of_groups = total_number_of_groups + 1
	if s:verbose > 1
	  call confirm('ord< \z\=(...\) > = '. pat_pos
		\ ."\npat = ".pat[pat_pos].pat[pat_pos+1]
		\ ."\nNb groups = ".total_number_of_groups
		\ , '&Ok', 1)
	endif
	" Define an associative table
	if pat[pat_pos+1] == 'z' " external group
	  let ext_i = ext_i + 1
	  let count_local_ext{ext_i} = total_number_of_groups
	else                     " internal group
	  let int_i = int_i + 1
	  let count_local_int{int_i} = total_number_of_groups
	endif
	" update loop condition: move to the next internal or external group
	let pat_pos = match(pat, '\\z\=(.\{-}\\)', pat_pos+1)
      endwhile
      " And then change every '\z(...\)' into '\(...\)'
      let pat = substitute(pat, '\\z(\(.\{-}\)\\)', '\\(\1\\)', 'g')
      
      " Finally, change every \z1, \z2 ... \z9 and \1 ... \9 into the updated
      " numbers: \z{k} or \{k}      -> \{n}
      let pat_pos = match(pat, '\\z\=\d')
      while pat_pos != -1
	if s:verbose > 1
	  call confirm('ord< \z\d > = '. pat_pos
		\ ."\npat = ".pat[pat_pos].pat[pat_pos+1].pat[pat_pos+2]
		\ , '&Ok', 1)
	endif
	" Retrieve the new number from the associative table
	if pat[pat_pos+1] == 'z' " external group: \zk -> \p
	  let nb = count_local_ext{pat[pat_pos+2]}
	else                     " internal group: \k  -> \p
	  let nb = count_local_int{pat[pat_pos+1]}
	endif
	" Update the old number in the pattern-string
	let pat = substitute(pat, '\(.\{'.(pat_pos+1).'}\)z\=\d', '\1'.nb, '')
	" Update loop condition: move to the next internal/external reference
	let pat_pos = match(pat, '\\z\=\d', pat_pos+2)
      endwhile

      " Renumber groups }}}
      
      if a:apply_ms_me " {{{
	if '' != zs
	  let pat = s:AddZs(pat, zs)
	endif
      endif " apply_ms_me }}}
      
      " The final pattern in a concatenation of all the syntax-patterns: {{{
      " ie: pattern <- '\n' . pat
      if '' == pattern
	let pattern = pat
      else
	let pattern = pattern . "\n" . pat
      endif
      let pat = ''
      " }}}
    endif
    " Next :syn item
    let list = matchstr(list, "\n\\zs.*")
  endwhile
  return pattern
endfunction
" }}}

" Function: s:MergeRegex_Comments_n_String               {{{
function! s:MergeRegex_Comments_n_String(comments, string)
  return ("" != a:string) ? (a:comments . '\|' . a:string) : (a:comments)
endfunction
" }}}

" Function: s:BuildRegex4String(ft)                      {{{
" Todo: manage the case when several kind of languages can be embedded in a
" same file ; e.g.: vimString, perlString, rubyString, tclString, pythonString
" with Vim scripts.
function! s:BuildRegex4String(ft)
  let ft = a:ft
  let string_regex = substitute(s:SynGroupPattern(ft, 'String', 1, 1), 
	\ "\n", '\\|', 'g' )
  " However, sometimes, the current syntax file does not define &ft.'String',
  " and we must look at the syntax it derives from. 
  " e.g.: in C++, there is no 'cppString', but a 'cString'
  command! -nargs=1 VSSearchSyn :let s:SearchSynFile=<q-args>
  while '' == string_regex
    if s:verbose >= 3
      call confirm('Search {rtp}/syntax/'.ft.'.vim', '&Ok', 1)
    endif
    let s:SearchSynFile = ''
    exe ':SearchInRuntime :VSSearchSyn syntax/'.ft.'.vim'
    if '' != s:SearchSynFile
      silent exe 'sp '.s:SearchSynFile
      let l = search('\%(ru\%[ntime]!\s\+syntax\|so\%[ource]\s\+<sfile>:p:h \)/.\+\.vim')
      if l > 0
	let ft = matchstr(getline(l), 
	      \ '\%(ru\%[ntime]!\s\+syntax\|so\%[ource]\s\+<sfile>:p:h \)/\zs.\+\ze\.vim')
	bw!
	let string_regex = substitute(s:SynGroupPattern(ft, 'String', 1, 1),
	      \ "\n", '\\|', 'g' )
	let s:exact_syn_ft_{a:ft} = ft
      else
	bw!
	" no recursion
	VSgErrorMsg 'Can not determine any regex to extract strings from <'.a:ft
	      \ .'> files'."\n[Recursion ended with <".ft.'>]'
	break
      endif
    else
      "not found
      VSgErrorMsg 'Can not determine any regex to extract strings from <'.a:ft
	    \ .'> files'."\n[Syntax file for <".ft.'> not found]'
      break
    endif
  endwhile
  delcommand VSSearchSyn

  return string_regex
endfunction
" }}}

" Function: s:GetRegex4String(ft)                        {{{
" Kind of proxy function that caches the patterns already built.
function! s:GetRegex4String(ft)
  if !exists('s:string_re_'.a:ft)
    let s:string_re_{a:ft} = s:BuildRegex4String(a:ft)
  endif
  return s:string_re_{a:ft}
endfunction

let s:string_re_sh = '"\%(\%(\\"\)\|\_.\)\{-}"' . '\|' . "'".'\_.\{-}'."'"
" }}}

" Function: s:CommentsAndStrings_re(ft)                  {{{
function! s:CommentsAndStrings_re(ft)
  " The regexs do not need to be exact ; close enough to limit the number of
  " words to process is nice
  "
  " The Strings-regexs will be deduced thanks to the current highlighting ;
  " they are simple enough to extract the pattern used.
  " It is not the case of comments. They will be defined thanks to an
  " exhaustive list -- stolen from EnhancedCommentify.
  let string_regex = s:GetRegex4String(a:ft)
  let last_ref = matchstr(string_regex, '.*\\\zs\d')
  if last_ref == '' | let last_ref = 1 | endif
  let heredoc_regex = substitute(s:SynGroupPattern(a:ft, 'HereDoc', 1, last_ref)
	      \ , "\n", '\\|', 'g' )
  let string_regex = s:MergeRegex_Comments_n_String(string_regex, heredoc_regex)
  let string_regex = substitute(string_regex, '\^', '\\n', 'g')

  " Return String + Comment regex {{{
  if a:ft =~ 'tex\|php\|html\|sgml\|xml\|docbook\|xslt\|dtd\|sgmllnx' 
    " No test for HTML, XML, SGML, ..., (La)TeX because these formats are
    " directly supported by iaspell.
    return ''
  elseif a:ft =~ '^\(abel\|vim\)$'
    return string_regex . '\|".*$' 
  elseif a:ft =~ '^\(b\|c\|css\|csc\|cupl\|indent\|jam\|lex\|lifelines\|' .
	\ 'lite\|nqc\|phtml\|progress\|rexx\|rpl\|sas\|sdl\|sl\|'.
	\ 'strace\|xpm\)$'
    return s:MergeRegex_Comments_n_String('/\*\_.\{-}\*/', string_regex)
  elseif a:ft =~ '^\(jgraph\|lotos\|mma\|modula2\|modula3\|pascal\|sml\)$' 
    return s:MergeRegex_Comments_n_String('(\*\_.\{-}\*)', string_regex)
  elseif a:ft =~ '^\(ox\|cpp\|php\|java\|verilog\|acedb\|ch\|clean\|'.
	\ 'clipper\|cs\|dot\|dylan\|hercules\|idl\|ishd\|javascript'.
	\ 'kscript\|mel\|named\|openroad\|pccts\|pfmain\|pike\|'.
	\ 'pilrc\|plm\|pov\|rc\|scilab\|specman\|tads\|tsalt\|uc\|'.
	\ 'xkb\)$'
    return s:MergeRegex_Comments_n_String('//.*$\|/\*\_.\{-}\*/', string_regex)
  elseif a:ft =~ '^\(plsql\|vhdl\|ahdl\|ada\|asn\|csp\|eiffel\|gdmo\|'.
	\ 'haskell\|lace\|lua\|mib\|sather\|sql\|sqlforms\|sqlj\|'.
	\ 'stp\)$'
    return s:MergeRegex_Comments_n_String('--.*$', string_regex)
  elseif a:ft =~ '^\(python\|perl\|[^w]*sh$\|tcl\|jproperties\|make\|'.
	\ 'robots\|apacha\|apachestyle\|awk\|bc\|cfg\|cl\|conf\|'.
	\ 'crontab\|diff\|ecd\|elmfilt\|eterm\|expect\|exports\|'.
	\ 'fgl\|fvwm\|gdb\|gnuplot\|gtkrc\|hb\|hog\|ia64\|icon\|'.
	\ 'inittab\|lftp\|lilo\|lout\|lss\|lynx\|maple\|mush\|'.
	\ 'muttrc\|nsis\|ocaml\|ora\|pcap\|pine\|po\|procmail\|'.
	\ 'psf\|ptcap\|r\|radiance\|ratpoison\|readline\remind\|'.
	\ 'ruby\|screen\|sed\|sm\|snnsnet\|snnspat\|snnsres\|spec\|'.
	\ 'squid\|terminfo\|tidy\|tli\|tsscl\|vgrindefs\|vrml\|'.
	\ 'wget\|wml\|xf86conf\|xmath\)$'
    return s:MergeRegex_Comments_n_String('#.*$', string_regex)
  elseif a:ft =~ '^\(amiga\|asm\|lisp\|scheme\|asm68k\|bindzone\|def\|'.
	\ 'dns\|dosini\|dracula\|dsl\|idlang\|iss\|jess\|kix\|masm\|'.
	\ 'monk\|nasm\|ncf\|omnimark\|pic\|povini\|rebol\|registry\|'.
	\ 'samba\|skill\|smith\|tags\|tasm\|tf\|winbatch\|wvdial\|'.
	\ 'z8a\)$'
    return s:MergeRegex_Comments_n_String('##.*$', string_regex)
  elseif exists('g:VS_grep_these_comments_'.a:ft)
    return s:MergeRegex_Comments_n_String(
	  \ g:VS_grep_these_comments_{a:ft}, string_regex)
  else                            
    return '' . string_regex
  endif
  " Return String + Comment regex }}}
endfunction
" }}}

" Function: s:F_parse_source_code()                      {{{
function! s:F_parse_source_code()
  " Retrieve the pattern that defines strings or comments
  let re = s:CommentsAndStrings_re(&ft)
  " Export debug info
  if s:verbose >= 3 | let g:re = re | endif
  " Open a new name-less buffer
  new
  " Write in this buffer the contents of the main buffer (the one to parse)
  silent 0r #
  
  " Purge everything that does not match the regex
  if &gdefault
    silent exe ':%s#\_.\{-}\('. escape(re, '#') .'\|\%$\)#\1\r#gge'
    " Reduce the number of words to spell-check
    " - One word per line!
    "   Todo: find something better than [:punct:]
    silent %s#\%([[:punct:]]\|\_s\)\+#\r#gg
  else
  silent exe ':%s#\_.\{-}\('. escape(re, '#') .'\|\%$\)#\1\r#ge'
  " Reduce the number of words to spell-check
  " - One word per line!
  "   Todo: find something better than [:punct:]
  silent %s#\%([[:punct:]]\|\_s\)\+#\r#g
  endif

  " - Sort the words
  if (SystemDetected() == 'msdos') && !UnixLayerInstalled()
    silent %Sort
    silent %Uniq
  else
    silent exe '%!'.SysSort('-u')
  endif

  " Todo: restore search history

  if s:verbose >= 4
    return 0
  endif

  " Parse the built buffer
  return s:F_parse_a_temporary('', expand('#:p:h'))
endfunction
" }}}

" Function: s:IsAProgrammingLanguageFT(ft) : boolean     {{{
function! s:IsAProgrammingLanguageFT(ft)
  " If updates done, check s:I_mode in VS_int-fun.vim
  return (a:ft != '') &&
	\ ( a:ft !~ 'tex' .
	\    '\|htm\|xml\|php\|xsl\|sgm\|docbk' .
	\    '\|nroff\|help' .
	\    '\|mail\|mgp' .
	\    '\|changelog')
endfunction
" }}}

" Function: s:Exact_syn_ft_(ft) : string                 {{{
" Returns the exact filetype-prefix for the current syntax.
" For instance s:Exact_syn_ft_c = 'c', s:Exact_syn_ft_cpp = 'c'
function! s:Exact_syn_ft_(ft)
  return exists('s:exact_syn_ft_'.a:ft) ? (s:exact_syn_ft_{a:ft}) : (a:ft)
endfunction
" }}}
" Pb: s:exact_syn_ft_{ft}is not defined until s:BuildRegex4String() is called
"   [C, C++ (w/ Vim < 6.2.72?)]
let s:exact_syn_ft_cpp = 'c'

" Function: s:So_containedin(stx,ft)                     {{{
" stx: 'str', 'comment', 'text'
let s:default_str = 'String'
let s:default_comment = 'Comment'
let s:default_text = ''

function! s:So_containedin(stx,ft)
  return s:Option('so_containedin_'.a:stx.'_'.a:ft, 
	\ a:ft.s:default_{a:stx}, 'gs')
endfunction
function! s:So_containedin_text(ft)
  return s:Option('so_containedin_text_'.a:ft, '', 'gs')
endfunction
function! s:So_containedin_str(ft)
  return s:Option('so_containedin_str_'.a:ft, a:ft.'String', 'gs')
endfunction
" }}}
let s:VS_so_containedin_str_sh = 'shSingleQuote,shDoubleQuote,shHereDoc'
let s:VS_so_containedin_text_changelog = 'changelogText,changelogHeader'
let s:VS_so_containedin_text_help = 'helpHeadLine,helpHeader,helpNormal'
let s:VS_so_containedin_text_mail = 'mailSignature'
"   [C, C++ (w/ Vim < 6.2.72?)]
let s:VS_so_containedin_str_c  = 'cString,cCppString'

" Function: s:Build_Or_Get_soContainedin(stx,ft)         {{{2
function! s:Build_Or_Get_soContainedin(stx,ft)
  let what = s:default_{a:stx}
  if s:SynList(a:ft.what) =~ 'contains=\S*@'.a:ft.what.'Group'
    exe 'syn cluster '. a:ft .what.'Group add=SpellErrors,Normal'
    return ''
  else " Try to guess
    return s:So_containedin(a:stx,a:ft)
  endif
endfunction

" Function: s:AdjustSyntax()                             {{{2
" Enable the highlighting of misspellings for the current filetype
function! s:AdjustSyntax()
  call s:CheckSpellLanguage()
  let ft = s:Exact_syn_ft_(&ft)
  if s:IsAProgrammingLanguageFT(ft)
    " With programming languages, we can expect the "misspellable" words can
    " only be found within @Spell, {ft}CommentGroup, {ft}String and
    " syntax-items like that.
    let b:spell_options = substitute(b:spell_options, 
	  \ '\(\s*\)\<contained\>\s\+\|$', '\1contained ', '')
  endif
  if     ft == 'tex'  " {{{3
    " vim 6.2.72-
    syn cluster texCommentGroup		add=SpellErrors,Normal
    " vim 6.2.73+
    syn cluster Spell	    	 	add=SpellErrors,Normal

    syn cluster texMatchGroup		add=SpellErrors,Normal
    " Sometimes, we don't want the next group to be searched ...
    syn cluster texCmdGroup		add=SpellErrors,Normal
  elseif ft == 'bib'  " {{{3
    syn cluster bibVarContents     	contains=SpellErrors,Normal
    syn cluster bibCommentContents 	contains=SpellErrors,Normal
  elseif ft == 'xml'  " {{{3
    syn cluster xmlText		     	add=SpellErrors,Normal
    syn cluster xmlRegionHook	 	add=SpellErrors,Normal
  elseif -1 != match(s:SynList('@Spell'), 'Spell\s\+cluster=')  " {{{3
    " Thanks to Claudio Fleiner's syntax files, we can use the @Spell
    " cluster to highlight misspellings.
    "   [cs, dtml, html, java, and m4 files (w/ vim 6.1) -> strings & comments]
    " After a discussion on vim@vim.org, other syntax-files support @Spell
    "   [amiga, c, c++, csh, dcl, elmfilt, exports, lex, lisp, mapple, sh, sm,
    "   vim, xmath  (w/ vim 6.2.073+ ?) -> comments only, no strings!]
    syn cluster Spell	    	 	add=SpellErrors,Normal
    "
    " Special treatment for doxygened files {{{4
    if s:SynList('doxygenComment') !~ 'E28'
      let so_containedin_comment = 
	    \ 'doxygenBody,doxygenSpecialOnelineDesc,'
	    \.'doxygenSpecialTypeOnelineDesc,doxygenHeaderLine,'
	    \.'doxygenSpecialMultilineDesc,doxygenPageDesc'
	    \.'doxygenSpecialSectionDesc'
      let b:spell_options = substitute(b:spell_options, ' containedin=\S*\|$', 
	    \ ' containedin='.so_containedin_comment, '')
    endif
  else                " {{{3
    if s:IsAProgrammingLanguageFT(ft)       " {{{4
      " Check whether {&ft}(Comment|String)Group are supported
      "
      " Highlight within comments ...                                  {{{5
      " CommentGroups:
      "   [b, csc, fortran, jam, nqc, plsql]
      "   [C, C++ (w/ Vim < 6.2.73?)]
      "   [amiga, csh, dcl, lisp, lpc, maple, sh, vim ? (w/ Vim < 6.2.73?)]
      let so_containedin_comment = s:Build_Or_Get_soContainedin('comment', ft)
      " if s:SynList(ft.'Comment') =~ 'contains=\S*@'.ft.'CommentGroup'
      " exe 'syn cluster '. ft .'CommentGroup add=SpellErrors,Normal'
      " let so_containedin_comment = ''
      " else " Try to guess
      " let so_containedin_comment = s:So_containedin('comment',ft)
      " endif

      " Special treatment for doxygened files {{{6
      "   [C, C++ & syntax/doxygen.vim (w/ Vim < 6.2.72?)]
      if s:SynList('doxygenComment') !~ 'E28'
	let so_containedin_comment = so_containedin_comment
	      \.((''!=so_containedin_comment) ? ',' : '')
	      \.'doxygenBody,doxygenSpecialOnelineDesc,'
	      \.'doxygenSpecialTypeOnelineDesc,doxygenHeaderLine,'
	      \.'doxygenSpecialMultilineDesc,doxygenPageDesc'
	      \.'doxygenSpecialSectionDesc'
      endif

      " ... and strings                                                {{{5
      " StringGroup: [vim]
      let so_containedin_str = s:Build_Or_Get_soContainedin('str', fr)
      " if s:SynList(ft.'String') =~ 'contains=\S*@'.ft.'StringGroup'
      " exe 'syn cluster '. ft .'StringGroup add=SpellErrors,Normal'
      " let so_containedin_str = ''
      " else "   [Any other filetype]
      " let so_containedin_str = s:So_containedin('str',ft)
      " endif
      " Note: if you want to extend other groups, it could be done within
      " appropriate syntax files/ftplugins.

      " Rebuild b:spell_options according to the 'containedin' field   {{{5
      let comma = (''!=so_containedin_comment) && (''!=so_containedin_str)
      let so_containedin = so_containedin_comment . 
	    \ (comma?',':'') . so_containedin_str
    else " text                               {{{4
      let so_containedin = s:So_containedin_text( ft)
    endif                                   " }}}4
    if 0 != strlen(so_containedin)
      let so_containedin = ' containedin='.so_containedin
    endif
    let b:spell_options = substitute(b:spell_options, ' containedin=\S*\|$', 
	  \ so_containedin, '')
  endif
endfunction
" }}}2

" Part:		lhVimSpell/prog. languages functions }}}1
"=============================================================================
" Part:		lhVimSpell/files management function {{{1
" Last Update:	31st Jan 2004
"------------------------------------------------------------------------
" Description:	Files Management functions for Vim-Spell to [ia]spell
"------------------------------------------------------------------------
" TODO:		«missing features»
"=============================================================================

"===========================================================================
" Function: s:FileExist({filename})                      {{{
function! s:FileExist(filename)
  if !filereadable(a:filename)
    call s:ErrorMsg("Error! " . a:filename . " does not exist!")
    return 0
  else
    return 1
  endif
endfunction " }}}
"===========================================================================
" Spell-check files                    {{{
"------------------------------------------------------------------------
" Function: s:F_parse_file(abspath2file,ft,dname) : bool {{{
" ie: -> call s:F_parse_file(expand('%:p'),&ft) : need the complete path
function! s:F_parse_file(filename,ft, dname)
  " 1- Retrieve the list of errors
    " note: as s:FileExist() is used, F_parse_file() can not be made
    " completely silent.
    if !s:FileExist(a:filename) 
      VSgErrorMsg "Can not spell-check the file <".a:filename."> ; it does not exist!"
      return 0
    endif
    let lst = s:I_list_errors(a:filename,a:ft)

  " 2- Check for new errors
    let no_new_error = -1 == s:CheckNewErrors(a:dname,lst)
    if no_new_error
      VSEchoMsg 'No new misspelling...' 
    endif

  " 3- Enter correction mode.
  "    Build the Syntax for error and the regex search.
    call s:Show_errors()

  return 1
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:M_Parse_current_file()                     {{{
function! s:M_Parse_current_file()
  if s:IsAProgrammingLanguageFT(&ft)
    if version < 602
      let do_it = confirm(
	    \"In order to spellcheck such files, the version 6.2 of Vim ".
	    \   "is required!\n\n"
	    \ ."Do you still want to parse the whole file (comments, string ".
	    \   "*and code*) ?"
	    \ , "&Yes\n&No", 1)
      if do_it == 1
	call s:F_parse_file(expand('%:p'),&ft,expand('%:p:h'))
      endif
    elseif !exists(':SearchInRuntime')
      let do_it = confirm(
	    \"In order to spellcheck such files, searchInRuntime is required!".
	    \ "\nYou can find it at: ".
	    \ "<http://hermitte.free.fr/vim/ressources/searchInRuntime.tar.gz>".
	    \ "\n\nDo you still want to parse the whole file (comments, string "
	    \."*and code*) ?"
	    \ , "&Yes\n&No", 1)
      if do_it == 1
	call s:F_parse_file(expand('%:p'),&ft,expand('%:p:h'))
      endif
      
    else " version OK
      call s:F_parse_source_code()
    endif
  else
    call s:F_parse_file(expand('%:p'),&ft,expand('%:p:h'))
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_parse_a_temporary(contents, dname): bool {{{
function! s:F_parse_a_temporary(contents,dname) 
  " 1- Prepare a temporary file
  let temp = tempname()

  " 2- Copy region to temp ...
  if '' != a:contents
    silent exe "split ".temp
    silent 0put=a:contents
    silent w 
  else
    " ... or use the current unamed buffer
    silent exe 'w '.temp
  endif
  silent bw!

  " 3- Parse the temporary file
  let res = s:F_parse_file(temp,&ft,a:dname)

  " 4- Purge the temporary file
  call delete(temp)
  return res
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:M_Parse_region()                           {{{
function! s:M_Parse_region() range
  let save_a = @a
  silent normal! gv"ay
  call s:F_parse_a_temporary(@a,expand('%:p:h'))
  let @a = save_a
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================
" Function: s:ExitSpell()                                {{{
" Clear errors
function! s:ExitSpell()
  if &ft != "vsgui" | call s:G_Open_Corrector() | endif
  silent bw!
  " clear the misspelled words
  silent syn clear
  " silent syntax on
  silent set syn=ON
  " Restore cmd height and folding authorization {{{
  if exists('s:fold_enable')
    if exists('s:line_height')
      silent let &cmdheight=s:line_height
      unlet s:line_height
    endif
    let &foldenable = s:fold_enable
    unlet s:fold_enable
    if has('gui_running') && has('menu')
      exe 'menu disable '.escape(s:menu_name.'Exit', ' \')
    endif
  endif " }}}
endfunction " }}}
"===========================================================================
" Show errors                          {{{
" Function: s:Show_errors()                              {{{
" -> start correction mode!
function! s:Show_errors()
    " Load errors-list, abort if none
    let elf = s:F_error_list_file(expand("%:p:h"))
    if ('' == elf) || !filereadable(elf) 
      VSgErrorMsg "No file parsed in this directory..."
      return 
    endif

    " Prepare a temp. file
    let tmp = tempname()
    silent exe "split ".tmp
    silent exe ':r '.elf

    " Delete the header
    silent g/^@(#)/d _
    """ todo: Delete Ignored words
    ""g/^I .*/d _

    " Build the SpellErrors syntax "pattern"                              {{{
    let v:errmsg = ''
    if !s:Option('show_ispell_guess', 1, 'g')
      silent! g/^? /d _
    endif
    silent! %s/^[&*#?] \(\S\+\).*$
	  \/exe 'syntax match SpellErrors "'. "\\\\<\1\\\\>" . '" '.b:spell_options
    if strlen(v:errmsg)
      " ie. no misspelling
      silent bw!
      call delete(tmp)
      return -1
    endif
    silent wq
    " }}}

    " Do highlight the misspellings
    syn case match
    syn match SpellErrors "xxxxx"
    syn clear SpellErrors

    " Enable the highlighting of misspellings for the current filetype
    call s:AdjustSyntax()
    " Actual color for misspellings ; todo: permit overriding
    hi default link SpellErrors Error


    " Highlight the misspellings                                          {{{
    "syn region Misspelling start="\k" end="\W*" contains=SpellErrors transparent
    exe "source ".tmp
    exe "silent bw! ".tmp
    call delete(tmp)
    
    " Load ignored words
    let ilf = s:F_ignore_list_file(expand("%:p:h"))
    if (""!=ilf) && filereadable(ilf)
      exe "so ".ilf
    endif
    " }}}

    " cmd-line of at least 2 height & deactivate folds                    {{{
    if !exists('s:fold_enable')
      if &cmdheight < 2
	silent let s:line_height = &cmdheight
	set cmdheight=2
      endif
      let s:fold_enable = &foldenable
      set nofoldenable
      if has('gui_running') && has('menu')
	exe 'menu enable '.escape(s:menu_name.'Exit', ' \')
      endif
    endif " }}}
    " silent call s:Maps_4_file_edited()
    return 1
endfunction " }}}
" }}}
"===========================================================================
"===========================================================================
" Names of the different files used    {{{
"
" Ex.: name of the file listing the errors
" 	-> <spath>/.spell/errors-list
" 	-> <spath>/.spell/ignore-list
" 	-> <spath>/.spell/spell-corrector
"------------------------------------------------------------------------
" Function: s:F_check_for_VS_path(path)                  {{{
" Check the sub directory ./.spell/ exists.
function! s:F_check_for_VS_path(path)
  let path = fnamemodify(a:path,':p:h')
  let path = fnamemodify(a:path . '/.spell', ':p')
  if !isdirectory(path)
    if filereadable(path)
      call s:ErrorMsg("A file is found were a folder is expected: " . path)
      return
    endif
    let v:errmsg=""
    if &verbose >= 1 | echo "Create <".path.">\n" | endif
    call system(SysMkdir(path))
    if strlen(v:errmsg) != 0
      call s:ErrorMsg(v:errmsg)
    elseif !isdirectory(path)
      VSgErrorMsg "Can't create <".path.">"
    endif
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_error_list_file(path)                    {{{
" Returns: 	The name of the errors list file according to the required path
" NB:		Checks the path exists
" Format:	by line: the one produced by «echo 'word' | aspell -a»
function! s:F_error_list_file(path)
  call s:F_check_for_VS_path(a:path)
  " return a:path . '/.spell/errors-list'
  return a:path . '/.spell/errors-list.'. 
	\ matchstr(fnamemodify(s:Personal_dict(), ':t'), '.*\ze\.pws$')
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_ignore_list_file(path)                   {{{
" Returns: 	The name of the file containing the ignored words according to
" 		the required path 
" NB:		Checks the path exists
function! s:F_ignore_list_file(path)
  call s:F_check_for_VS_path(a:path)
  " return a:path . '/.spell/ignore-list'
  return a:path . '/.spell/ignore-list.'.
	\ matchstr(fnamemodify(s:Personal_dict(), ':t'), '.*\ze\.pws$')
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_corrector_file(path)                     {{{
" Returns:	The name of the file used for the corrector buffer
let s:spell_corrector_bname = 'spell-corrector-'
function! s:F_corrector_file(path)
  let path = fnamemodify(a:path . '/.spell', ':p:h')
  return a:path. '/.spell/'.s:spell_corrector_bname.fnamemodify(tempname(), ':t')
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================
" Build Alternatives for a list of misspellings {{{
"------------------------------------------------------------------------
" Function: s:CheckNewErrors(path,misspellings)          {{{
" Purpose: Check for new misspellings
function! s:CheckNewErrors(path,errors)
  " 0- File name of the list-errors file
    let elf = s:F_error_list_file(a:path)

  " 1- Comparison
  "    i-  If did not exist => add everything
  "    ii- add what is new
  " 1.1- Determine what the new errors are
    if !filereadable(elf) | let new = a:errors
    else                  | let new = s:F_compare(elf,a:errors)
    endif
  " 1.2- Build their alternatives
    let tmp = s:F_build_alternatives(new)
    if "" == tmp
      return -1
    endif
  " 1.3- Add them to elf
    call FindOrCreateBuffer(elf,1)	" from a.vim
    silent exe "$r ".tmp
    silent g/^$/d _
    " Keep only one the header line produced by aspell.
    let save_a = @"
    silent g/^@(#)/d a
    silent 0put=@a
    let @a = save_a
    " Write and quit errors-list
    silent w! | silent bw
    " Purge intermediary buffer
    silent exe "bw ".tmp
    call delete(tmp)
    return 1
endfunction
" }}} 
"------------------------------------------------------------------------
" Function: s:F_compare(elf,misspellings)                {{{
" Compare new errors to errors-list    
function! s:F_compare(elf,errors)
    call FindOrCreateBuffer(a:elf,1)	" from a.vim
    let new="" | let er=a:errors
    while "" != er
      let word = matchstr(er, "[^\n]*")
      ""echo "word  -- " . word . "\n"
      let er   = substitute(er, "[^\n]*\n".'\(.*\)$', '\1', '')
      ""echo "er    -- " . er . "\n"
      if search('^[#*&?] \<'.word.'\>') <= 0
	let new = new . "\n" . word
      endif
      ""echo "found -- " . found . "\n"
    endwhile
    silent bw
    return new
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_build_alternatives(misspellings)         {{{
" Build Alternatives for a list of misspellings 
function! s:F_build_alternatives(misspellings)
  return s:I_get_alternatives(a:misspellings)
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================
"===========================================================================
" Management of dict. & ignored words  {{{
"------------------------------------------------------------------------
" Function: s:M_AddWord(word, lowcase [, dirname] )      {{{
" Called by the main-buffer mode mapping VS_add and VS_ass_low
function! s:M_AddWord(word,lowCase,...)
  let dname = ((a:0>0) && (a:1 != '')) ? a:1 : expand('%:p:h')
  if s:F_AddWord(a:word,a:lowCase,dname)
    call s:Show_errors()
    redraw
    let word  = (a:lowCase) ? tolower(a:word) : (a:word)
    VSEchoMsg '<'.word.'> has been added to the personal dictionary'
    if g:VS_jump_to_next_error_after_validation 
      call s:SpchkNext() 
    endif
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_AddWord(word, lowcase, dirname )         {{{
function! s:F_AddWord(word,lowCase, dirname)

  " 2- Request to the spell checker
  if 0==s:I_add_word_to_dict(a:word,a:lowCase)
    return 0
  endif
  
  " 3- Update the cached file
  let elf = s:F_error_list_file(a:dirname)
  if "" == elf | return 0 | endif
  silent exe "split ".elf
  silent exe 'g/^[&#*?]\s*'.a:word.'\s*/d'
  silent w | silent bw

  return 1
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:M_IgnoreWord(word)                         {{{
" Called by the main-buffer mode mapping VS_ignore
function! s:M_IgnoreWord(word)
  if s:F_add_word_to_ignore_file(a:word)
    redraw
    VSEchoMsg '<'.a:word.'> will be ignored for the files in this directory'
    if g:VS_jump_to_next_error_after_validation 
      call s:SpchkNext() 
    endif
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:F_add_word_to_ignore_file(word) : boolean  {{{
function! s:F_add_word_to_ignore_file(word)
  " 1- Determine the file having the word ignored.
  let ilf = s:F_ignore_list_file(expand("%:p:h"))
  if "" == ilf 
    VSgErrorMsg "Can't find the file archiving the ignored words!"
    return 0
  endif

  " 2- Add the pattern to the "ignore" file
  silent exe "split ".ilf
  if search('/'.a:word.'/$') == 0
    let li="exe 'syn match Normal /'.".'"'.a:word.'"'.".'/ transparent contains=NONE '.b:spell_options"
    silent $put=li
  endif
  silent w | silent bw

  " 3- Instant patch to the current syntax highlighting
  let spell_options = s:CheckSpellLanguage()
  exe 'syn match Normal /'.a:word.'/ transparent contains=NONE '.spell_options
  return 1
endfunction
" }}}
"------------------------------------------------------------------------
" }}}
"===========================================================================
" Move from one error to the next {{{
"
" Functions stolen in David Campbell's engspchk.vim
" -------------------------------------------------------------------
" Function: s:SpchkNext([called-from-corrector-buffer]) {{{
" Returns: 1 in case of a successful jump, 0 otherwise
function! s:SpchkNext(...)
  " Check weither we must update the corrector window
  let called_from_corrector = (a:0 > 0) && a:1
  if !called_from_corrector
    let nr = bufnr('*spell-corrector-*.tmp')
    if (-1 != nr ) && (-1 != bufwinnr(nr))
      execute bufwinnr(nr). ' wincmd w'
      return s:G_NextError()
    endif
  endif

  " Normal treatment
  let errid = hlID("SpellErrors")
  let lastline= line("$")
  let curcol  = 0
  let pos = line('.').'normal! '.virtcol('.').'|'

  silent! norm! w

  " skip words until we find next error
  while synID(line("."),col("."),1) != errid
    silent! norm! w
    if line(".") == lastline
      let prvcol=curcol
      let curcol=col(".")
      if curcol == prvcol 
	exe pos
	VSgErrorMsg 'No next misspelling'
	return 0
      endif
    endif
  endwhile

  return 1
endfunction
" }}}
" -------------------------------------------------------------------
" Function: s:SpchkPrev([called-from-corrector-buffer]) {{{
" Returns: 1 in case of a successful jump, 0 otherwise
function! s:SpchkPrev(...)
  " Check weither we must update the corrector window
  let called_from_corrector = (a:0 > 0) && a:1
  if !called_from_corrector
    let nr = bufnr('*spell-corrector-*.tmp')
    if (-1 != nr ) && (-1 != bufwinnr(nr))
      execute bufwinnr(nr). ' wincmd w'
      return s:G_PrevError()
    endif
  endif

  " normal treatment
  let errid = hlID("SpellErrors")
  let curcol= 0
  let pos = line('.').'normal! '.virtcol('.').'|'

  silent! norm! b

  " skip words until we find previous error
  while synID(line("."),col("."),1) != errid
    silent! norm! b
    if line(".") == 1
      let prvcol=curcol
      let curcol=col(".")
      if curcol == prvcol 
	exe pos
	VSgErrorMsg 'No previous misspelling'
	return 0
      endif
    endif
  endwhile

  return 1
endfunction
" }}}
" -------------------------------------------------------------------
" }}}

" Part:		lhVimSpell/file management function }}}1
"=============================================================================
" Part:		lhVimSpell/mappings for the corrector buffer {{{1
" Last Update:	05th Sep 2003
"------------------------------------------------------------------------
" Description:	Defines the mappings and menus for the Corrector buffer.
"------------------------------------------------------------------------
" TODO:		«missing features»
"=============================================================================

"===========================================================================
" Help                                 {{{2
"------------------------------------------------------------------------
function! s:Add2help(msg, help_var) " {{{3
  if (!exists(a:help_var))
    exe 'let ' . a:help_var . '   = a:msg'
    exe 'let ' . a:help_var . 'NB = 0'
  else
    exe 'let ' . a:help_var . ' = ' . a:help_var . '."\n" . a:msg'
  endif
  ""let g:vsgui_help_maxNB = g:vsgui_help_maxNB+1
  exe 'let ' . a:help_var . 'NB = ' . a:help_var . 'NB + 1 '
endfunction " }}}3
"------------------------------------------------------------------------
if !exists(":VSAHM") " {{{3
  command! -nargs=1 VSAHM call s:Add2help(<args>,"s:vsgui_help")
  VSAHM  "@| <cr>, <double-click> : Replace with current word"
  VSAHM  "@| <A>                  : Replace every occurrence of the misspelled word "
  VSAHM  "@|                        within the checked buffer"
  VSAHM  "@| <B>                  : Replace every occurrence of the misspelled word "
  VSAHM  "@|                        within all buffers"
  VSAHM  "@| <esc>                : Abort"
  VSAHM  "@| *, &                 : Add word to the dictionary (may be in lower case)"
  VSAHM  "@| <i>                  : Ignore the word momentarily"
  VSAHM  "@| <cursors>, <tab>     : Move between entries"
  VSAHM  "@|"
  VSAHM  "@| <u>/<C-R>            : Undo/Redo last change"
  VSAHM  "@| <M-n>, <M-p>         : Move between misspelled words in the checked buffer"
  VSAHM  "@| ?                    : Don't display this help"
  VSAHM  "@+-----------------------------------------------------------------------------"

  command! -nargs=1 VSAHM call s:Add2help(<args>,"s:vsgui_short_help")
  VSAHM  "@| ?                    : Display the help"
  VSAHM  "@+-----------------------------------------------------------------------------"
endif " }}}3
"------------------------------------------------------------------------
function! s:G_help() " {{{3
  if g:VS_display_long_help	| return s:vsgui_help
  else				| return s:vsgui_short_help
  endif
endfunction " }}}3
"------------------------------------------------------------------------
function! s:G_help_NbL() " {{{3
  " return 1 + nb lignes of BuildHelp
  if g:VS_display_long_help	| return 1 + s:vsgui_helpNB
  else				| return 1 + s:vsgui_short_helpNB
  endif
endfunction " }}}3
"------------------------------------------------------------------------
function! s:Toggle_gui_help() " {{{3
  let g:VS_display_long_help = 1 - g:VS_display_long_help
  silent call s:G_MakeAlternatives(b:word)
endfunction " }}}3
"------------------------------------------------------------------------
" }}}
" ======================================================================
" Mappings and menus                   {{{2
"------------------------------------------------------------------------
" Function: s:G_AltLoadMaps()                            {{{3
function! s:G_AltLoadMaps()
  nnoremap <silent> <buffer> <cr>	:call <sid>SA_return(line('.'))<cr>
  nnoremap <silent> <buffer> <2-LeftMouse> :call <sid>SA_return(line('.'))<cr>
  nnoremap <silent> <buffer> A		:call <sid>SA_all(line('.'))<cr>
  nnoremap <silent> <buffer> B		:call <sid>SA_all_buffers(line('.'))<cr>
  nnoremap <silent> <buffer> *		:call <sid>G_AddWord(0)<cr>
  nnoremap <silent> <buffer> &		:call <sid>G_AddWord(1)<cr>
  nnoremap <silent> <buffer> i		:call <sid>G_IgnoreWord()<cr>
  nnoremap <silent> <buffer> <esc>	:call <sid>SA_return(-1)<cr>

  nnoremap <silent> <buffer> <s-tab>	:call <sid>G_NextChoice(0)<cr>
  nnoremap <silent> <buffer> <tab>	:call <sid>G_NextChoice(1)<cr>

  nnoremap <silent> <buffer> <M-n>	:call <sid>G_NextError()<cr>
  nnoremap <silent> <buffer> <M-p>	:call <sid>G_PrevError()<cr>

  nnoremap <silent> <buffer> u		:call <sid>G_UndoCorrection(1)<cr>
  nnoremap <silent> <buffer> <c-r>	:call <sid>G_UndoCorrection(0)<cr>
  nnoremap <silent> <buffer> <M-s>E	:call <sid>ExitSpell()<CR>
  nnoremap <silent> <buffer> ?		:call <sid>Toggle_gui_help()<cr>

  nnoremap <buffer> <k0>		:VSChooseWord 0
  nnoremap <buffer> <k1>		:VSChooseWord 1
  nnoremap <buffer> <k2>		:VSChooseWord 2
  nnoremap <buffer> <k3>		:VSChooseWord 3
  nnoremap <buffer> <k4>		:VSChooseWord 4
  nnoremap <buffer> <k5>		:VSChooseWord 5
  nnoremap <buffer> <k6>		:VSChooseWord 6
  nnoremap <buffer> <k7>		:VSChooseWord 7
  nnoremap <buffer> <k8>		:VSChooseWord 8
  nnoremap <buffer> <k9>		:VSChooseWord 9
  nnoremap <buffer> 0			:VSChooseWord 0
  nnoremap <buffer> 1			:VSChooseWord 1
  nnoremap <buffer> 2			:VSChooseWord 2
  nnoremap <buffer> 3			:VSChooseWord 3
  nnoremap <buffer> 4			:VSChooseWord 4
  nnoremap <buffer> 5			:VSChooseWord 5
  nnoremap <buffer> 6			:VSChooseWord 6
  nnoremap <buffer> 7			:VSChooseWord 7
  nnoremap <buffer> 8			:VSChooseWord 8
  nnoremap <buffer> 9			:VSChooseWord 9
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:G_AltLoadMenus()                           " {{{3
function! s:G_AltLoadMenus()
  let s:menu_start= 'menu <silent>'.s:menu_prio.'.200 '.s:menu_name
  let name = escape(s:menu_name, '\ ')
  " call s:AddMenuItem('a', 200, '-3-', '', '<c-l>')
  exe 'nunmenu '.name.'Add\ to\ &dictionary<tab>'.s:map_leader.'*'
  exe 'nunmenu '.name.'Idem\ low&case<tab>'.s:map_leader.'\&'
  exe 'nunmenu '.name.'&Ignore\ word<tab>'.s:map_leader.'i'
  call s:AddMenuItem('n', 200, 'Add to &dictionary', '*', '*')
  call s:AddMenuItem('n', 200, 'Idem low&case',      '&', '&')
  call s:AddMenuItem('n', 200, '&Ignore word',       'i', 'i')

  call s:AddMenuItem('a', 210, '-4-', '', '<c-l>')

  call s:AddMenuItem('n', 500, '&Undo', 'u', 'u')
  call s:AddMenuItem('n', 500, 'Re&do', '<c-r>', '<c-r>')

  call s:AddMenuItem('n', 510, '&Next misspelling', s:map_leader.'n', ':call <sid>G_NextError()<cr>')
  call s:AddMenuItem('n', 510, '&Prev misspelling', s:map_leader.'n', ':call <sid>G_PrevError()<cr>')

  exe 'menu disable '.escape(s:menu_name.'Run spell checker', ' \')
  exe 'menu disable '.escape(s:menu_name.'Show misspellings', ' \')
  exe 'menu disable '.escape(s:menu_name.'Show alternatives', ' \')
  IfTriggers 
	\ exe 'menu disable '.escape(s:menu_name.'Change Language', ' \')
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:G_AltUnloadMenus()                         "{{{3
function! s:G_AltUnloadMenus()
  let name = escape(s:menu_name, '\ ')
  " exe 'aunmenu '.name.'-3-'
  exe 'nunmenu '.name.'Add\ to\ &dictionary<tab>*'
  exe 'nunmenu '.name.'Idem\ low&case<tab>\&'
  exe 'nunmenu '.name.'&Ignore\ word<tab>i'
  call s:AddMenuItem('n', 200, 'Add to &dictionary', s:map_leader.'*', '<Plug>VS_add')
  call s:AddMenuItem('n', 200, 'Idem low&case',      s:map_leader.'\&', '<Plug>VS_add_low')
  call s:AddMenuItem('n', 200, '&Ignore word',       s:map_leader.'i', '<Plug>VS_ignore')
  exe 'aunmenu '.name.'-4-'
  exe 'nunmenu '.name.'&Undo<tab>u'
  exe 'nunmenu '.name.'Re&do<tab><c-r>'

  call s:AddMenuItem('n', 510, '&Next misspelling', s:map_leader.'n', '<Plug>VS_nextE')
  call s:AddMenuItem('n', 510, '&Prev misspelling', s:map_leader.'p', '<Plug>VS_prevE')

  exe 'menu enable '.escape(s:menu_name.'Run spell checker', ' \')
  exe 'menu enable '.escape(s:menu_name.'Show misspellings', ' \')
  exe 'menu enable '.escape(s:menu_name.'Show alternatives', ' \')
  IfTriggers 
	\ exe 'menu enable '.escape(s:menu_name.'Change Language', ' \')
endfunction
" }}}3
"------------------------------------------------------------------------
" }}}2

" Part:		lhVimSpell/mappings for the corrector buffer }}}1
"=============================================================================
" Part:		lhVimSpell/corrector buffer functions {{{1
" Last Update:	14th Jul 2005
"------------------------------------------------------------------------
" Description:	Syntax and functions for VIM-spell GUI
"------------------------------------------------------------------------
" Note:
" (*) Whenever it is possible, add the single-quote to the keyword thanks
"     to set isk+='
"     Could be done with no harm with LaTeX, mail, and other text formats
" TODO:		«missing features»
"=============================================================================

"===========================================================================
" Syntax    {{{2
"===========================================================================
" Function: s:G_AltSyntax()                              {{{3
function! s:G_AltSyntax()
  if has("syntax")
    syn clear

    syntax region AltLine  start='\d' end='$' contains=AltNumber,AltAlternative
    syntax region AltNbOcc  start='^--' end='$' contains=AltNumber,AltName
    syntax match AltNumber /\d\+/ contained
    syntax match AltName /<\S\+>/ contained
    syntax match AltAlternative /\S\+$/ contained

    syntax region AltExplain start='@' end='$' contains=AltStart
    syntax match AltStart /@/ contained
    syntax match Statement /--abort--/

    highlight link AltExplain Comment
    highlight link AltStart Ignore
    highlight link AltLine Normal
    highlight link AltName Identifier
    highlight link AltAlternative Identifier
    highlight link AltNumber Number
  endif
endfunction 
" }}}3
" }}}2
"===========================================================================
" Functions {{{2
"===========================================================================
" Function: s:G_Open_Corrector()                         {{{3
function! s:G_Open_Corrector()
  " open the corrector gui (split window)
  let gui = s:F_corrector_file(expand('%:p:h'))
  call FindOrCreateBuffer(gui,1)	" from a.vim
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nobuflisted
endfunction 
" }}}3
"------------------------------------------------------------------------
" Function: s:Current_Word()                             {{{3
function! s:Current_Word()
  let save_isk = &isk
  " Plus: for French, may be Italian and some other languages
  set isk+='
  set isk+=-
  " Minus: all the programmation stuff... not working -> TODO
  " set isk-=&~#{[()]}`_=$*%!:/;.?\\
  " set isk-=|
  " set isk-=,
  " set isk-=^
  let word     = expand("<cword>")
  let &isk     = save_isk
  return word
endfunction

function! s:IsWord(word)
  let save_isk = &isk
  " Plus: for French, may be Italian and some other languages
  set isk+='
  set isk+=-
  " Minus: all the programmation stuff...not working -> TODO
  " set isk-=&~#{[()]}`_^=$*%!:/;.?\\
  " set isk-=|
  " set isk-=,
  let res = (a:word =~ '^\K\+$')
  " call confirm('word='.a:word."\n isk=".&isk."\n res=".res, '&ok', 1)
  let &isk     = save_isk
  return res
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:G_Launch_Corrector()                       {{{3
function! s:G_Launch_Corrector()
  " Means that the current window is not the Corrector window.
  let word     = s:Current_Word()
  let filename = expand("%")
  let W1       = winnr()
  let lang     = s:Language()

  call s:G_Open_Corrector()

  " transfert variables
  ""let b:word	 = word
  let b:filename    = filename
  let b:mainfile    = filename
  let b:W1	    = W1
  let b:W2	    = winnr()
  let b:VS_language = lang

  " Display the alternatives for the current word
  call s:G_AltSyntax()
  call s:G_MakeAlternatives(word)
endfunction 
" }}}3
"------------------------------------------------------------------------
" Function: s:G_MakeAlternatives(word)                   {{{3
" Build the alternatives for the current word
function! s:G_MakeAlternatives(word)
  " Note: :redraw is needed in order to let the upcoming echoings correclty
  " happen. It seems that otherwise, :split delays a :redraw just before the
  " user have the focus.
  redraw
  VSEchoMsg ''

  " 0- Purge vsgui                               {{{4
  silent! %delete _

  " 1- Find word in errors-list                  {{{4
  let elf = s:F_error_list_file(fnamemodify(b:filename,':p:h'))
  if ("" == elf ) || !filereadable(elf)
    VSgErrorMsg "You need to parse some files first...  \nArborted!"
    silent bw!
    return 
  endif
  silent exe ':0r '.elf
  silent! exe '2,$v/^[&#*?] '.a:word.'\s\+/d _'
  let b:word = a:word

  " 2- Convert the list                          {{{4
  " 2.a- The help string                              {{{5
  if "" == b:word
    silent! 2,$g/^[@#&*?]/d _
    silent! 2,$g/^$/d _
  endif
  let NbL = s:G_help_NbL()
  silent 1put = s:G_help()

  " 2.b- Special case: no word under the cursor       {{{5
  if "" == a:word
    silent $put ='-- No word selected'
    silent $put =''
    silent $put ='  --abort--'
    VSEchoMsg 'No word selected...'
    return
  " elseif !s:IsWord(a:word)                          {{{5
  elseif (a:word !~ '\K\+') || (line('$') > NbL+1)
    " Some damn characters are keywords, and are such than several entries in
    " the errors-list file are kept (instead of only one entry).
    if line('$') > NbL+1
      exe 'silent '.(NbL+1).',$delete _'
    endif
    silent $put ='-- <'.a:word.'> is not a word'
    silent $put =''
    silent $put ='  --abort--'
    VSEchoMsg 'Incorrect word selected...'

  " 2.c- The suggested alternatives                   {{{5
  elseif search('^& .* \d\+ \d\+:') > 0
    let NbL = NbL + 1
    silent call s:G_mk_Alternatives(NbL)
    silent exe NbL."put = ''"
    silent put = '  --abort--'

  " 2.d- Just an known misspelling,                   {{{5
  " but with no alternatives to propose
  elseif search('^# .* \d\+') > 0
    silent $delete _
    silent $put ='-- No suggestion available for <'.a:word.'>'
    silent $put =''
    silent $put ='  --abort--'
    VSEchoMsg "No suitable alternative for <".a:word.">..."

  " 2.e- This is a correct word                       {{{5
  elseif search('^\*') > 0
    silent $delete _
    silent $put ='-- <'.a:word.'> is correct...'
    silent $put =''
    silent $put ='  --abort--'
    VSEchoMsg "The word <".a:word."> is correct..."
    " TODO: must ask for sound-like words
  
  " 2.f- This is a guess (ispell specific)            {{{5
  elseif search('^?') > 0
    let NbL = NbL + 1
    silent call s:G_mk_Alternatives(NbL)
    silent exe NbL."put = ''"
    silent put = '  --abort--'

  " 2.g- The word has never been checked by iaspell   {{{5
  else " there are no alternative ; word never checked
    silent $put ='-- No suggestion available for <'.a:word.'>'
    silent $put =''
    silent $put ='  --abort--'
    VSEchoMsg "The word <".a:word."> has been not checked yet..."
    " TODO: process a:word on the fly.

  " 2.end-                                            {{{5
  endif

  ""call SpellAltMaps()

  " 3- Move the cursor to the first alternative  {{{4
  call s:G_NextChoice(1)

  " 4- A little message ...                      {{{4
  if !exists('b:VS_first_time_in_correction_mode')
    VSEchoMsg "\rCorrection mode activated..."
    let b:VS_first_time_in_correction_mode = 1
    " automatically unlet when the buffer is dismissed (:bw)
  endif
endfunction " }}}3
"------------------------------------------------------------------------
" Function: s:G_mk_Alternatives(NbL)                     {{{3
" -> known misspellings for which we can suggest corrections
" Note: must be called with `:silent'
function! s:G_mk_Alternatives(NbL)
  " Number the entries
  if &gdefault
    s/[:,]/\r##\t/gg
  else
  s/[:,]/\r##\t/g
  endif
  %s/##/\="\t".(line('.')-a:NbL)/
  " Number of entries
  let NbAlt = matchstr(getline(a:NbL), '^[&?] \S\+ \zs\d\+\ze') + 1
  " Special treatment for Ispell's guesses ("?")
  if search("^\t".NbAlt) == line('$')
    exe "$s#\t".'.*\s\+\(.*\)#. [Ispell thinks it is: <\1>]'
    let save_a = @a
    $delete a
    exe a:NbL."put=@a"
    exe a:NbL.'normal! J'
    let @a = save_a
  endif
  " Build the prompt-like line.
  silent! exe a:NbL.':s/^& \(.\{-}\) \(\d\+\) \d\+/-- \2 alternatives to <\1>/'
  silent! exe a:NbL.'s/^? \(.\{-}\) \d\+ \d\+/-- <\1> seems OK/'
  " todo: Be sure the maximum number of guesses (Ispell's "?") is 1
endfunction
" }}}3
"------------------------------------------------------------------------
"===========================================================================
"===========================================================================
" Choose from a number {{{3
"
" Does not work very well ...
command! -nargs=1 VSChooseWord :call s:G_ChooseWord(<q-args>)

" Function: s:G_ChooseWord(nb)
function! s:G_ChooseWord(nb)
  let nb = a:nb+3+s:G_help_NbL()
  if a:nb < 0 || nb>line('$')
    VSgErrorMsg "Invalid number, no alternative word corresponding"
  elseif nb == 0
    silent bw!
    VSgErrorMsg "Abort"
  else
    call s:SA_return(nb)
    " silent exe ":".nb
    " silent exe "normal \<cr>"
  endif
endfunction 
" }}}3
"===========================================================================
" Choose from gui -- <cr> or <2-leftclick>
"------------------------------------------------------------------------
" Function: s:SA_PromoteAlternative(word,position)       {{{3
function! s:SA_PromoteAlternative(word,position)
  if 1 == a:position | return 1 | endif
  " 1- Open errors-list                  {{{4
  let elf = s:F_error_list_file(fnamemodify(b:filename,':p:h'))
  if ("" == elf ) || !filereadable(elf)
    VSgErrorMsg 'Unexpected error in SA_PromoteAlternative: can not open <'
	  \ .elf.'>'
    return 0
  endif
  silent exe ':sp '.elf

  " 2- Promote the selected alternative  {{{4
  silent exe 'g/& \<'.a:word.'\> \d\+ \d\+:/ s#:\(\%(,\= [^,]\+\)\{' .
	\ (a:position-1) . '}\), \([^,]\+\)#: \2,\1#'

  " 3- Close errors-list                 {{{4
  silent w | bw
  return 1
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:SA_GetAlternative(line)                    {{{3
function! s:SA_GetAlternative(line)
  let NbL = s:G_help_NbL()+3
  if (a:line == NbL) || (a:line == -1)
    return ""
  elseif a:line > NbL
    call s:SA_PromoteAlternative(b:word, a:line - 3 - s:G_help_NbL())
    return substitute(getline(a:line), '^.*\s\+', '', '')
  else
    return -1
  endif
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:SA_return(line)                            {{{3
function! s:SA_return(line)
  let alt = s:SA_GetAlternative(a:line)
  if (strlen(alt) != 0) 
    if (alt != -1)
      ""let b_ID = bufnr('%')
      let W_ID = b:W1+1
      let word = b:word
      "swap windows
      let this = expand('%:p')
      call FindOrCreateBuffer(b:mainfile,1)
      let go = s:Current_Word() == word
      if !go
	VSgErrorMsg "<".word."> lost! Use <M-n> to go to next occurrence\n"
      else
	" Use a temporary mapping to change the word without enabling
	" embedded mappings to expand.
	"exe "normal! viwc" . alt . "\<esc>"
	exe "nnoremap =}= viwc".alt."\<esc>"
	silent exe "normal =}="
	unmap =}=
      endif
      "swap windows
      call FindOrCreateBuffer(this,1)
      if go
	VSEchoMsg '<'.word.'> has been replaced with <'.alt.'>'
	VSgNextError
      endif
    endif
  else
    silent bw!
    VSEchoMsg "\rAbort"
  endif
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:SA_all(line)                               {{{3
function! s:SA_all(line)
  let alt = s:SA_GetAlternative(a:line)
  if (strlen(alt) != 0) 
    if (alt != -1)
      let b_ID = bufnr('%')
      ""let W_ID = b:W1+1
      let word = b:word
      "swap windows
      ""exe "normal! ".W_ID."\<c-W>x"
      silent exe 'b '.b:mainfile
      silent exe '%s/'.word.'/'. alt.'/g' . (&gdefault ? 'g' : '')
      silent normal! "\<c-v>\<c-l>"
      "swap windows
      ""exe "normal! ".W_ID."\<c-W>x"
      silent exe ' b'.b_ID
      VSEchoMsg 'Every occurences of <'.word.'> have been replaced with <'.alt.'>'
      VSgNextError
    endif
  endif
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: s:SA_all_buffers(line)                       {{{3
function! s:SA_all_buffers(line)
  let alt = s:SA_GetAlternative(a:line)
  if (strlen(alt) != 0) 
    if (alt != -1)
      let word = b:word
      let b_ID = bufnr('%')
      let b_last = bufnr('$')
      let i = 1
      while i != b_last
	if i != b_Id
	  silent exe 'b '.i
	  silent exe '%s/'.word.'/'. alt.'/g' . (&gdefault ? 'g' : '')
	endif
	let i = i + 1
      endwhile
      " reload the good buffer
      silent exe ' b'.b_ID
      VSEchoMsg 'Every occurences of <'.word.'> have been replaced with <'
	    \ .alt.'> in every buffer'
      VSgNextError
    endif
  endif
endfunction
" }}}3
"------------------------------------------------------------------------

"===========================================================================
" Move to choice {{{3
function! s:G_NextChoice(isForward)
  call search('^\s*\d\+\s\+\zs', a:isForward ? '' : 'b')
endfunction
" }}}3
"===========================================================================
" Move to errors {{{3
function! s:G_NextError()
  let this = expand('%:p')
  call FindOrCreateBuffer(b:mainfile,1)
  let res = s:SpchkNext(1)
  let word = s:Current_Word()
  call FindOrCreateBuffer(this,1)
  call s:G_MakeAlternatives(word)
  return res
endfunction

function! s:G_PrevError()
  let this = expand('%:p')
  call FindOrCreateBuffer(b:mainfile,1)
  let res = s:SpchkPrev(1)
  let word = s:Current_Word()
  call FindOrCreateBuffer(this,1)
  call s:G_MakeAlternatives(word)
  return res
endfunction

command! -nargs=0 VSgNextError 
      \ :if g:VS_jump_to_next_error_after_validation |
      \    call s:G_NextError() |
      \ endif

" }}}3
"===========================================================================
" Undo {{{3
function! s:G_UndoCorrection(isUndo)
  let this = expand('%:p')
  call FindOrCreateBuffer(b:mainfile,1)
  if a:isUndo == 1 | undo
  else             | redo
  endif
  let word = s:Current_Word()
  call FindOrCreateBuffer(this,1)
  call s:G_MakeAlternatives(word)
endfunction
" }}}3
"===========================================================================
" Add words to the dictionary & Ignore words {{{3
"===========================================================================
" Called by the corrector-buffer mode mappings
"
function! s:G_AddWord(lowCase)
  if s:F_AddWord(b:word,a:lowCase,fnamemodify(b:filename,':p:h'))
    call s:G_ReShowErrors()
    redraw
    let word  = (a:lowCase) ? tolower(b:word) : (b:word)
    VSEchoMsg '<'.word.'> has been added to the personal dictionary'
    VSgNextError
  endif
endfunction

function! s:G_IgnoreWord()
  let this = expand('%:p')
  let word = b:word
  call FindOrCreateBuffer(b:mainfile,1)
  let res = s:F_add_word_to_ignore_file(word)
  call FindOrCreateBuffer(this,1)
  redraw
  if res
    VSEchoMsg '<'.word.'> will be ignored for the files in this directory'
    VSgNextError
  endif
endfunction

function! s:G_ReShowErrors()
  let this = expand('%:p')
  call FindOrCreateBuffer(b:mainfile,1)
  call s:Show_errors()
  call FindOrCreateBuffer(this,1)
endfunction
" }}}3
" }}}2
"===========================================================================
" Load the maps {{{2
"===========================================================================
"
" Rem: name of the file type must be simple ; for instance VS_gui does not
" fit, but vsgui does.
"
" Could and must be converted to vim6 -- alternative

aug VS_g_Alternative_AU
  au!
  au BufNewFile,BufRead spell-corrector* set ft=vsgui
aug END
if has('gui_running') && has('menu')
  aug VS_g_Alternative_AU
    au BufEnter           spell-corrector* silent call s:G_AltLoadMenus()
    au BufLeave           spell-corrector* silent call s:G_AltUnloadMenus()
  aug END
endif
au Syntax vsgui silent call s:G_AltLoadMaps()
" }}}2

" Part:		lhVimSpell/corrector buffer functions }}}1
"=============================================================================
"
"------------------------------------------------------------------------
"=============================================================================
" vim600: set fdm=marker:
