"=============================================================================
" File:         autoload/lh/buffermenu.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"               <URL:http://github.com/LucHermitte/lh-misc>
" Version:      2.0.0
let s:k_version = 2.0.0
" Created:      16th Nov 2016
" Last Update:  24th Nov 2016
"------------------------------------------------------------------------
" Description:
"       See comments in plugin/buffermenu.vim
"
"------------------------------------------------------------------------
" History: {{{2
" v2.0.0:
"       - Move functions to autoload
"       - Use lh-vim-lib logging framework
"       - Fix error on buffer unloading
"       - Fix display of (local)leader value
"
" Design: {{{2
" * A struct-like type is used to store menu definitions. This is achieved
" thanks to vim7' dictionaries. The fields are the following:
" - name: (string) full name of the menu entry (contains the ampersands used to
"   mark hot-keys)
" - priority: (string) priority of the menu
" - mode: (i(nsert)|n(ormal)|c(command)|v(visual)) mode of the menu entry
" - nore: (0/1) tells whether the execution of the action will trigger mappings
"   and abbreviations (see |noremenu|)
" - action: (string) action to execute when the menu-entry is selected
" - useenable: (0/1) tells whether the entry will be unset or disabled.
" - state: designs the state of the entry:
"   - "non-existant": the menu-entry doesn't appear anywhere
"   - "set"         : the menu-entry is currently active
"   - "disabled"    : the menu-entry is momentarily disabled
"
"
"   The state machine is the following:
"   CreateMenu()  ------->  "non-existant"   <----
"                          /   ^      |            \
"               -----------    |      |             \
"              /   UnsetMenu() |      | SetMenu()    |
"              \               |      v              /
" RestoreMenu() >------------>  "set"   >-----------<­ UnloadMenu()
"              /               ^      |              \
"              \  EnableMenu() |      | DisableMenu() |
"               \              |      v              /
"                ------------ "disabled"      <-----
"
" * The functions used in the state-machine are:
" - UnloadMenu() which decides to unset or disable the menu-entry according to
"   the useenable field.
" - RestoreMenu() which restores an unloaded menu-entry.
" - UnsetMenu(), EnableMenu(), SetMenu() and DisableMenu() are low-evel
"   functions that are used by RestoreMenu() and UnloadMenu(). These are the
"   functions that call vim's :menu commands
"
" * All the menus are stored into two global variables:
" - s:menus: List of all the menus indexed by their {name}##{mode}
" - s:menu_{buffer-id}:

" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#buffermenu#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#buffermenu#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#buffermenu#debug(expr) abort
  return eval(a:expr)
endfunction

" Function: lh#buffermenu#dump_menu([bufferid] {{{3
function! lh#buffermenu#dump_menu(...) abort
  let bid = (a:0 > 0) ? (a:1) : bufnr('%')
  if exists('s:menus_'.bid)
    echo "##[".bid." buffer's menus]\n".string(s:menus_{bid})."\n"
  endif

  echo "##[All buffer-menus]\n".string(s:menus)
  echo "##[Visible buffer-menus]\n".string(s:crt_menus)
endfunction

" # Misc    {{{2
" s:getSNR([func_name]) {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

"------------------------------------------------------------------------
" ## Plugin   functions {{{1
" Function: lh#buffermenu#_define(bang, ...) {{{3
" Works out what arguments were passed to the command.
"  Use ! for 'noremenu'
function! lh#buffermenu#_define(bang, ...) abort
  let n=1
  let modes=''
  if a:{n} =~ '^[anvoic]*$'
    let modes=a:{n}
    let n += 1
  endif
  let silent = ''
  let useenable= exists('g:buffermenu_use_disable') && g:buffermenu_use_disable
  while 1
    if a:{n} ==? '<silent>'
      let silent = '<silent> '
      let n += 1
    elseif a:{n} ==? '<unmenu>'
      let useenable=0
    elseif a:{n} ==? '<disable>'
      let useenable=1
    else
      break
    endif
  endwhile
  let menunumber=''
  if a:{n} =~ '^\s*\d\+\(\.\d\+\)*'
    let menunumber=a:{n}.' '
    let n += 1
  endif
  if a:0 >= (n+1)
    let menuname=escape(a:{n},' ')
    let menucmd=a:{n+1}
    let n += 2
    while n <= a:0
      let menucmd=menucmd.' '.a:{n}
      let n += 1
    endwhile
    call s:BufferMenu( a:bang=='!', useenable, modes, silent, menunumber.menuname, menucmd )
  else
    let cmd='('.modes.')menu'.a:bang.' '.menunumber.' ^^ '
    let x=n
    while x<= a:0
      let cmd=cmd.' {'.escape(a:{x},' ').'}'
      let x += 1
    endwhile
    echoerr 'Invalid arguments: '.cmd
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#buffermenu#_clear_all() : undefines all the buffer-menus ever registered {{{3
" @param list-of-buffer-id
" @param "<buffer>" <=> current buffer
" @param nothing    <=> every buffers
function! lh#buffermenu#_clear_all(...) abort
  let bids_list = (a:0 > 0) ? (a:000) : keys(s:buffers_list)

  for bid in bids_list
    if (bid ==? '<buffer>') | let bid =  bufnr('%') | endif
    if exists('s:menus_'.bid)
      for m in values(s:menus_{bid})
        call s:UnsetMenu(m)
        unlet s:menus_{bid}[m.key]
      endfor
      unlet s:buffers_list[bid]
    endif
    " postcondition: sets must have been cleared
    if !empty(s:menus_{bid})
      echoerr 'Assertion failed: '.bid."'s s:menus_{bid} not cleared"
    endif
  endfor

  if a:0 == 0
    " Clear every thing: just be sure
    let s:menus     = {}
    let s:crt_menus = {}
  endif
endfunction

" ## Internal functions {{{1
" # Helper functions {{{2
function! s:SetKey(menu) abort " {{{3
  call s:Verbose("Computes key of %1", a:menu)
  let key = a:menu.name . '##' . a:menu.mode
  let a:menu["key"] = key
endfunction

" Function: FindBufferSID() {{{3
" Execute the result of this to make sure that <SID> works when creating menus
" Example:
"      exe FindBufferSID()
fun! lh#buffermenu#FindBufferSID() abort
  return 'imap zzzzzzz <SID>|let t_z=@z|redir @z|silent imap zzzzzzz |let b:bmenu_sid_t=matchstr(@z,"<SNR>\\d\\+_$")|let @z=t_z|unlet t_z|iunmap zzzzzzz'
endfun

"------------------------------------------------------------------------
" # Management of current menu {{{2
" Init internal maps {{{3
if ! exists('s:crt_menus')
  " The plugin may be reloaded. This does not mean the menus should not be
  " cleared
  " s:menus_{bid}           : list of menus in a buffer
  let s:menus        = {} " : dict of managed menus
  let s:crt_menus    = {} " : dict of currently visible menu-enties
  let s:buffers_list = {} " : set of buffer for which there are local menus
endif

function! s:IsCurrent(menu) abort " {{{3
  let key = a:menu.key
  return has_key(s:crt_menus, key) && (a:menu is s:crt_menus[key])
endfunction

function! s:IsTextVisible(menu) abort " {{{3
  let key = a:menu.key
  return has_key(s:crt_menus, key)
endfunction

function! s:SetCurrent(menu) abort " {{{3
  let key = a:menu.key
  let s:crt_menus[key] = a:menu
endfunction

function! s:ClearFromCurrent(menu) abort " {{{3
  if s:IsCurrent(a:menu)
    let key = a:menu.key
    unlet s:crt_menus[key]
  endif
endfunction

function! s:ClearFromGlobal(menu) abort " {{{3
  let key = a:menu.key
  if has_key(s:menus, key)
    let menus_list = s:menus[key]
    let idx = 0
    while idx < len(menus_list)
      if a:menu is menus_list[idx]
        call remove(menus_list, idx)
      else
        let idx += 1
      endif
    endwhile
    if empty(menus_list)
      unlet s:menus[key]
    endif
  endif
endfunction

"------------------------------------------------------------------------
" # Define menu {{{2
" Function: FindMenu() : Finds or creates a menu according to parameters {{{3
" The menu is identified by its name + its mode
" Menus are shared across all buffers
function! s:FindMenu(name, priority, mode, nore, action, silent, useenable) abort
  " Current buffer-id
  let bid = bufnr('%')
  " Key to identified the menu-entry in the entries list
  let key = a:name.'##'.a:mode

  " Is the menu already known in the current buffer ?
  if exists('s:menus_'.bid)
    if has_key(s:menus_{bid}, key)
      let menu = s:menus_{bid}[key]
      call s:Verbose("  Menu found (%1)", menu)
      return menu
    endif
  else
    " No menu in this buffer => prepare an empty dictionary.
    let s:menus_{bid} = {}
  endif

  " Else: Ask the global list of menus
  let menu = s:Search(a:name, a:priority, a:mode, a:nore, a:action, a:silent, a:useenable)
  let s:menus_{bid}[key] = menu
  let menu.ref_count += 1
  let s:buffers_list[bid] = 1
  return menu
endfunction

" Function: TryDefineMenu() : Fetches a menu defined by its name, priority, ... {{{3
" @post menu.state == "set"
function! s:TryDefineMenu(name, priority, mode, nore, action, silent, useenable) abort
  let menu = s:FindMenu(a:name, a:priority, a:mode, a:nore, a:action, a:silent, a:useenable)
  call s:Verbose(" New menu: %1", menu)
  " TODO: Check if we can remove it thanks to the autocommand
  return s:RestoreMenu(menu)
endfunction

" Function: BufferMenu : Do define the menu {{{3
fun! s:BufferMenu(dontremap, useenable, modes, silent, menuname, mapping) abort
  let noRe = a:dontremap ? 'nore' : ''
  call s:Verbose("BufferMenu%1)", [noRe, a:useenable ? 'useenable' : 'remove', a:modes, a:silent, a:menuname, a:mapping])
  let mll= escape(lh#leader#get_local(), '\|')
  let ml = escape(lh#leader#get()      , '\|')

  let menuname=substitute(a:menuname,'\c<localleader>',escape(mll,"\\"), 'g')
  let menuname=substitute(menuname,  '\c<leader>',     escape(ml, "\\"), 'g')

  if exists('b:bmenu_sid_t')
    let mapping=substitute(a:mapping, '\c<sid>',b:bmenu_sid_t, 'g')
  else
    if match(a:mapping, '\c<sid>') >= 0
      echoerr 'You must have "exe FindBufferSID()" before adding buffer menus with <SID>!'
      return
    endif
    let mapping=a:mapping
  endif

  " Get the modes - if nothing, use the default.
  let ma=0
  let modes=a:modes
  if modes==''
    let modes=' ' " Execute a 'menu' command without prefix
  endif

  " Execute
  let name    =substitute(menuname,'^\s*\d[0-9.]*','','')
  let priority=matchstr  (menuname,'^\s*\d[0-9.]*')
  while ma < len(modes)
    let res = s:TryDefineMenu(name, priority, modes[ma], noRe, mapping, a:silent, a:useenable)
    if !res | break | endif
    let ma += 1
  endwhile
endfunction

" # Search menu {{{2
" Function: Compare()  : Compares a menu-entry with a menu-definition {{{3
function! s:Compare(menu, name, priority, mode, nore, action, useenable) abort
  let equals =
        \    a:menu.name     == a:name
        \ && a:menu.priority == a:priority
        \ && a:menu.mode     == a:mode
        \ && a:menu.nore     == a:nore
        \ && a:menu.action   == a:action
        \ && a:menu.useenable== a:useenable
  return equals
endfunction

" Function: Search() {{{3
function! s:Search(name, priority, mode, nore, action, silent, useenable) abort
  let menu = {}
  let key = a:name.'##'.a:mode
  if has_key(s:menus, key)
    let menus_list = s:menus[key]
    for a_menu in menus_list
      if s:Compare(a_menu, a:name, a:priority, a:mode, a:nore, a:action, a:useenable)
        let menu = a_menu
        call s:Verbose("   (Global) Found menu %1", menu)
        break
      endif
    endfor
  else
    let menus_list = []
    let s:menus[key] = menus_list
  endif
  if empty(menu)
    let menu = s:CreateMenu(a:name, a:priority, a:mode, a:nore, a:action, a:silent, a:useenable)
    call add( menus_list, menu )
    call s:Verbose("   (Global) New menu added: %1", menu)
  endif
  return menu
endfunction

" # State Management {{{2
" States {{{3
let s:k_state_nonexistant = 'non-existant'
let s:k_state_set         = 'set'
let s:k_state_disabled    = 'disabled'

" Function: CreateMenu()  : creates a new menu entry {{{3
function! s:_to_string() dict abort
  if s:verbose > 1
    return self._old_2string()
  else
    " Clear "\" occurrences, but not "\\"
    let name = substitute(self.name, '\v\\@<!\\\\@!', '', 'g')
    return lh#fmt#printf('(%{1.state}) %{1.mode}%{1.nore} %2', self, name)
  endif
endfunction

function! s:CreateMenu(name, priority, mode, nore, action, silent, useenable) abort
  let res = lh#object#make_top_type({})
  let res.name         = a:name
  let res.priority     = a:priority
  let res.mode         = a:mode
  let res.nore         = a:nore
  let res.action       = a:action
  let res.state        = s:k_state_nonexistant
  let res.silent       = a:silent
  let res.useenable    = a:useenable
  let res.ref_count    = 0
  let res._old_2string = res._to_string " from lh#object
  let res._to_string   = function(s:getSNR('_to_string'))
  call s:SetKey(res)
  call s:Verbose("Create buffer menu: %1", res)
  return res
endfunction

" Function: Exec()        : executes VimL commands {{{3
" @return whether the execution was successful
function! s:Exec(cmd) abort
  let erm=v:errmsg
  let v:errmsg=""
  exe a:cmd
  call s:Verbose("   :%1 --> %2", a:cmd, v:errmsg)
  if v:errmsg!=""
    echoerr 'In command: '.a:cmd
    return 0
  else
    let v:errmsg = erm
    return 1
  endif
endfunction

" Function: SetMenu()     : defines the menu-entry {{{3
" @pre  menu.state == "non-existant"
" @post menu.state == "set"
function! s:SetMenu(menu) abort
  call s:Verbose("  SetMenu(%1)", a:menu)
  if a:menu.state != s:k_state_nonexistant
    call assert_false(1, "Unexpected state (".a:menu.state.") when before setting menu (".string(a:menu).")")
  endif
  let cmd = a:menu.mode . a:menu.nore . 'menu ' . a:menu.silent . a:menu.priority
        \ . ' ' . a:menu.name . ' ' . a:menu.action
  let res = s:Exec(cmd)
  if res
    let a:menu.state    = s:k_state_set
    call s:SetCurrent(a:menu)
  endif
  return res
endfunction

" Function: UnsetMenu()   : undefines the menu-entry {{{3
" @pre  menu.state == "set"
" @post menu.state == "non-existant" if ref_count==1
function! s:UnsetMenu(menu) abort
  call s:Verbose("  UnsetMenu(%1)", a:menu)
  if a:menu.state != s:k_state_set
    call assert_false(1, "Unexpected state (".a:menu.state.") when before unsetting menu (".string(a:menu).")")
  endif
  let a:menu.ref_count -= 1
  if a:menu.ref_count == 0
    if s:IsTextVisible(a:menu)
      if s:IsCurrent(a:menu)
        let cmd = a:menu.mode . 'unmenu '
              \ . substitute(a:menu.name, '&\@<!&&\@!', '', 'g')
        let res = s:Exec(cmd)
      else
        return s:DisableMenu(a:menu)
      endif
    else
      let res = 1
    endif
    let a:menu.state    = s:k_state_nonexistant
    call s:ClearFromCurrent(a:menu)
    call s:ClearFromGlobal (a:menu)
    return res
  else
    " question: what about the state ?
    return 0
  endif
endfunction

" Function: EnableMenu()  : enables the menu-entry {{{3
" @pre  menu.state == "disabled"
" @post menu.state == "set"
function! s:EnableMenu(menu) abort
  call s:Verbose("  EnableMenu(%1)", a:menu)
  if a:menu.state != s:k_state_disabled
    call assert_false(1, "Unexpected state (".a:menu.state.") when before enabling menu (".string(a:menu).")")
  endif
  let cmd = a:menu.mode . 'menu enable' . ' '
        \ . substitute(a:menu.name, '&\@<!&&\@!', '', 'g')
  let res = s:Exec(cmd)
  let a:menu.state    = s:k_state_set
  return res
endfunction

" Function: DisableMenu() : disables the menu-entry {{{3
" @pre  menu.state == "set"
" @post menu.state == "disabled"
function! s:DisableMenu(menu) abort
  call s:Verbose("  DisableMenu(%1)", a:menu)
  if a:menu.state != s:k_state_set
    call assert_false(1, "Unexpected state (".a:menu.state.") when before disabling menu (".string(a:menu).")")
  endif
  let cmd = a:menu.mode . 'menu disable' . ' '
        \ . substitute(a:menu.name, '&\@<!&&\@!', '', 'g')
  let res = s:Exec(cmd)
  let a:menu.state    = s:k_state_disabled
  return res
endfunction

" Function: RestoreMenu() : restores the entry to the "set" state. {{{3
" @pre  menu.state != "set"
" @post menu.state == "set"
function! s:RestoreMenu(menu) abort
  call s:Verbose(" RestoreMenu(%1)", a:menu)
  let isCurrent = s:IsCurrent(a:menu)
  if a:menu.state == s:k_state_nonexistant || !isCurrent
    return s:SetMenu(a:menu)
  elseif a:menu.state == s:k_state_disabled
    return s:EnableMenu(a:menu)
  else " if a:menu.state == s:k_state_set
    " May happen in the scenario:
    " 1- create a new buffer => define the menu
    " 2- BufEnter -> restore this menu...
  endif
endfunction

" Function: UnloadMenu()  : unloads the menu-entry {{{3
" @pre menu.state == "set"
" @post menu.state == "disabled"     if menu.useenable
" @post menu.state == "non-existant" if not menu.useenable
function! s:UnloadMenu(menu) abort
  call s:Verbose(" UnloadMenu(%1)", a:menu)
  if a:menu.state == s:k_state_set
    if a:menu.useenable
      return s:DisableMenu(a:menu)
    else
      return s:UnsetMenu(a:menu)
    endif
  else
    call assert_false(1, "Unexpected state (".a:menu.state.") when before unloading menu (".string(a:menu).")")
  endif
endfunction

" # Auto commands {{{2
" Function: UnloadMenus()  : unloads all the buffer-menus for the current buffer {{{3
function! s:UnloadMenus() abort
  let bid = bufnr('%')
  call s:Verbose("UnloadMenus bid: %1", bid)
  if exists('s:menus_'.bid)
    for m in values(s:menus_{bid})
      call s:UnloadMenu(m)
    endfor
  endif
endfunction

" Function: RestoreMenus() : restores all the buffer-menus for the current buffer {{{3
function! s:RestoreMenus() abort
  let bid = bufnr('%')
  call s:Verbose("RestoreMenus bid: %1", bid)
  if exists('s:menus_'.bid)
    for m in values(s:menus_{bid})
      call s:RestoreMenu(m)
    endfor
  endif
endfunction

" Function: UnloadBuffer() : unloads all information related to no-longer existing buffer {{{3
function! s:UnloadBuffer(bid) abort
  let bid = a:bid
  call s:Verbose("UnloadBuffer a:bid: %1", bid)
  if exists('s:menus_'.bid)
    unlet s:menus_{bid}
  endif
  if has_key(s:buffers_list, bid)
    unlet s:buffers_list[bid]
  endif
endfunction

" Autocommands to unload and restore buffer-menus {{{3
" Note: no need to register any thing until a buffer menu is defined
aug MRGBufferMenuEnter
  au!
  au BufEnter   * call s:RestoreMenus()
  au BufLeave   * call s:UnloadMenus()
  au BufUnload  * call s:UnloadBuffer(expand('<abuf>'))
aug END

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
