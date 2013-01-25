" Buffer Menus - Add menus to the current buffer only.
" Author: Michael Geddes <michaelrgeddes@optushome.com.au>
" Version: 1.9.3
" URL: http://vim.sourceforge.net/scripts/script.php?script_id=246
"
" Contributions by Luc Hermitte
" LH's Disclaimer: sometimes ago I've patched this plugin in order to it to
" have a better stability. Unfortunately, my HD crashed soon after the last
" version. I can't be sure I've restored the lastest version.
" I should spent some time to test everything thoroughly but I've never found
" the courage to do so again. 
" So here it is. So far it seems to do its job, but it may have bugs that I did
" fix. In case you see them, drop me a word.
" --Luc Hermitte

if !has('gui_running') || &compatible
	finish
endif

let s:cpo_save=&cpo
set cpo&vim

" Usage -
" :Bmenu[!] ["<silent>"] ["<unmenu>"|"<disable>"] [<modes>] [<priority>] <Menuname> <Mapping>
"       Add menus to different modes for the current buffer.  (Bang is used to
"        specify 'noremenu')
" :B[ivacn]menu[!]["<silent>"] ["<unmenu>"|"<disable>"]  [<priority>] <Menuname> <Mapping>
"       Add menu for one mode (or 'a' for all modes) for the current buffer.
"       (Bang is used to specify 'noremenu')
"
":B[ivacn]noremenu ["<silent>"] ["<unmenu>"|"<disable>"] [<modes>] [<priority>] <Menuname> <Mapping>
"       Adds a 'norecursive' menu.
"
" The above commands accept '<silent>' as a flag to do a silent mapping.
" They also allow <SID> (providing you have done the "exe FindBufferSID()"
" at the beginning of the script), and will expand <leader> and <localleader>
" in menu names.
"
" :Bunmenuall
"       Remove all menus for the current buffer
"
" BufferOneShot( <ident> )
"       Use this to make sure Bmenus only get added ONCE per buffer.
"       eg:
"       if BufferOneShot('MyProgram')
"           Bmenu 10.20 Test.Test iHello<esc>
"       endif
"       A buffer local-variable called b:buffer_oneshot_MyProgram will be
"       created (just in case you want to unlet it when testing).
"
" exe FindBufferSID() 
"       :exe the result of this function when using <SID> in menu commands so that the correct
"       function gets called.
"


" TODO: 
"  * Add a 'Bunmenu' for one menu.
"  * If the same menu is added twice to the same mode, update the first entry rather than just
"    adding it twice (there _will_ be an error on leaving the buffer if this
"    happens, as there will be two unmenus for the same mode).

" Examples -
"  Bmenu ni 10.30 Test.It Test
"  Bimenu 10.40 Test.More Hello<esc>
"  Bamenu Test.Ignore :set ic<cr>

com! -nargs=+ -bang -complete=menu Bmenu  call <SID>DoBufferMenu(<q-bang>, <f-args> )
com! -nargs=+ -bang -complete=menu Bimenu call <SID>DoBufferMenu(<q-bang>, 'i', <f-args> )
com! -nargs=+ -bang -complete=menu Bvmenu call <SID>DoBufferMenu(<q-bang>, 'v', <f-args> )
com! -nargs=+ -bang -complete=menu Bamenu call <SID>DoBufferMenu(<q-bang>, 'a', <f-args> )
com! -nargs=+ -bang -complete=menu Bcmenu call <SID>DoBufferMenu(<q-bang>, 'c', <f-args> )
com! -nargs=+ -bang -complete=menu Bnmenu call <SID>DoBufferMenu(<q-bang>, 'n', <f-args> )
com! -nargs=?                  Bunmenuall call <SID>ClearBufferMenus(<f-args>)

com! -nargs=+ -complete=menu Bnoremenu    call <SID>DoBufferMenu('!', <f-args> )
com! -nargs=+ -complete=menu Binoremenu   call <SID>DoBufferMenu('!', 'i', <f-args> )
com! -nargs=+ -complete=menu Bvnoremenu   call <SID>DoBufferMenu('!', 'v', <f-args> )
com! -nargs=+ -complete=menu Banoremenu   call <SID>DoBufferMenu('!', 'a', <f-args> )
com! -nargs=+ -complete=menu Bcnoremenu   call <SID>DoBufferMenu('!', 'c', <f-args> )
com! -nargs=+ -complete=menu Bnnoremenu   call <SID>DoBufferMenu('!', 'n', <f-args> )


" Works out what arguments were passed to the command.
"  Use ! for 'noremenu'
fun! s:DoBufferMenu( bang, ...)
    let n=1
    let modes=''
    if a:{n} =~ '^[anvoic]*$' 
        let modes=a:{n}
        let n=n+1
    endif
    let silent = ''
    let useenable= exists('g:buffermenu_use_disable') && g:buffermenu_use_disable
    while 1
        if a:{n} ==? '<silent>'
            let silent = '<silent> '
            let n = n + 1
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
        let n=n+1
    endif
    if a:0 >= (n+1)
        let menuname=escape(a:{n},' ')
        let menucmd=a:{n+1}
        let n=n+2
        while n <= a:0
            let menucmd=menucmd.' '.a:{n}
            let n=n+1
        endwhile
        call s:BufferMenu( a:bang=='!', useenable, modes, silent, menunumber.menuname, menucmd )
    else
        let cmd='('.modes.')menu'.a:bang.' '.menunumber.' ^^ '
        let x=n
        while x<= a:0
            let cmd=cmd.' {'.escape(a:{x},' ').'}'
            let x=x+1
        endwhile
        echoerr 'Invalid arguments: '.cmd
    endif
endfun

" --------------------- %< -----------------------
" LH's modifications
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
" RestoreMenu() >------------>  "set"   -----------­< UnloadMenu()
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

" ========================================
" Helper functions
function! s:SetKey(menu)
    " call confirm( "Computes key of ".string(a:menu), '&Ok', 1)
    let key = a:menu.name . '##' . a:menu.mode
	let a:menu["key"] = key
endfunction

" Execute the result of this to make sure that <SID> works when creating menus
" Example:
"      exe FindBufferSID() 
fun! FindBufferSID()
	return 'imap zzzzzzz <SID>|let t_z=@z|redir @z|silent imap zzzzzzz |let b:bmenu_sid_t=matchstr(@z,"<SNR>\\d\\+_$")|let @z=t_z|unlet t_z|iunmap zzzzzzz'
endfun

" ========================================
" Management of current menu
if ! exists('s:crt_menus')
    " The plugin may be reloaded. This does not mean the menus should not be
    " cleared
    let s:crt_menus    = {} " dict of currently visible menu-enties
    let s:buffers_list = {} " set of buffer for which there are local menus
endif

function! s:IsCurrent(menu)
    let key = a:menu.key
    if has_key(s:crt_menus, key)
        return a:menu is s:crt_menus[key]
    endif
endfunction

function! s:IsTextVisible(menu)
    let key = a:menu.key
    return has_key(s:crt_menus, key)
endfunction

function! s:SetCurrent(menu)
    let key = a:menu.key
    let s:crt_menus[key] = a:menu
endfunction

function! s:ClearFromCurrent(menu)
    if s:IsCurrent(a:menu)
		let key = a:menu.key
        unlet s:crt_menus[key]
    endif
endfunction

" ========================================
" State Management
" Function: CreateMenu() : creates a new menu entry
function! s:CreateMenu(name, priority, mode, nore, action, silent, useenable)
    let res = {}
    let res.name     = a:name
    let res.priority = a:priority
    let res.mode     = a:mode
    let res.nore     = a:nore
    let res.action   = a:action
    let res.state    = 'non-existant'
    let res.silent   = a:silent
    let res.useenable= a:useenable
    let res.ref_count= 0
	call s:SetKey(res)
    return res
endfunction

" Function: Exec() : executes VimL commands
" @return whether the execution was successful
function! s:Exec(cmd)
    let erm=v:errmsg
    let v:errmsg=""
    exe a:cmd
    " call confirm( a:cmd." --> ".v:errmsg, '&Ok', 1)
    if v:errmsg!="" 
        echoerr 'In command: '.a:cmd
        return 0
    else
        let v:errmsg = erm
        return 1
    endif
endfunction

" Function: SetMenu() : defines the menu-entry
" @post menu.state == "set"
function! s:SetMenu(menu)
    let cmd = a:menu.mode . a:menu.nore . 'menu ' . a:menu.silent . a:menu.priority
                \ . ' ' . a:menu.name . ' ' . a:menu.action
    let res = s:Exec(cmd)
    if res
        let a:menu.state    = 'set'
        call s:SetCurrent(a:menu)
    endif
    return res
endfunction

" Function: SetMenu() : undefines the menu-entry
" @post menu.state == "non-existant" if ref_count==1
function! s:UnsetMenu(menu)
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
        let a:menu.state    = 'non-existant'
        call s:ClearFromCurrent(a:menu)
        call s:ClearFromGlobal (a:menu)
        return res
    else
        " question: what about the state ?
        return 0
    endif
endfunction

" Function: SetMenu() : enables the menu-entry
" @post menu.state == "set"
function! s:EnableMenu(menu)
    let cmd = a:menu.mode . 'menu enable' . ' '
				\ . substitute(a:menu.name, '&\@<!&&\@!', '', 'g') 
    let res = s:Exec(cmd)
    let a:menu.state    = 'set'
    return res
endfunction

" Function: SetMenu() : disables the menu-entry
" @post menu.state == "disabled"
function! s:DisableMenu(menu)
    let cmd = a:menu.mode . 'menu disable' . ' '
				\ . substitute(a:menu.name, '&\@<!&&\@!', '', 'g') 
    let res = s:Exec(cmd)
    let a:menu.state    = 'disabled'
    return res
endfunction

" ========================================
" 

" s:menus_{bid} : list of menus in a buffer
if ! exists('s:menus')
    " The plugin can be reloaded. This does not mean the menus should not be
    " clear-able
    let s:menus = {}     " dict of managed menus
    let s:crt_menus = {} " dict of currently visible menu-enties
endif

" Function: Compare() : Compares a menu-entry with a menu-definition
function! s:Compare(menu, name, priority, mode, nore, action, useenable)
    let equals =
                \    a:menu.name     == a:name
                \ && a:menu.priority == a:priority
                \ && a:menu.mode     == a:mode
                \ && a:menu.nore     == a:nore
                \ && a:menu.action   == a:action
                \ && a:menu.useenable== a:useenable
    return equals
endfunction

function! s:ClearFromGlobal(menu)
    let key = a:menu.key
    if has_key(s:menus, key)
        let menus_list = s:menus[key]
        let idx = 0
        while idx != len(menus_list)
            if a:menu is menus_list[idx]
                call remove(menus_list, idx)
                if empty(menus_list)
                    unlet s:menus[key]
                endif
                return
            endif
            let idx = idx + 1
        endwhile
    endif
endfunction

function! s:Search(name, priority, mode, nore, action, silent, useenable)
    let menu = {}
    let key = a:name.'##'.a:mode
    if has_key(s:menus, key)
        let menus_list = s:menus[key]
        for a_menu in menus_list
            if s:Compare(a_menu, a:name, a:priority, a:mode, a:nore, a:action, a:useenable)
                let menu = a_menu
				if &verbose > 0
					echom "found: ".string(menu)
				endif
                break
            endif
        endfor
    else 
        let menus_list = []
        let s:menus[key] = menus_list
    endif
    if empty(menu)
        let menu = s:CreateMenu(a:name, a:priority, a:mode, a:nore, a:action, a:silent, a:useenable)
		if &verbose > 0
			echom "Adding a new menu ".string(menu)
		endif
        call add( menus_list, menu )
    endif
    return menu
endfunction

" Function: FindMenu() : Finds or creates a menu according to parameters
" The menu is identified by its name + its mode
" Menus are shared across all buffers
function! s:FindMenu(name, priority, mode, nore, action, silent, useenable)
    " Current buffer-id
    let bid = bufnr('%')
    " Key to identified the menu-entry in the entries list
    let key = a:name.'##'.a:mode

    " Is the menu already known in the current buffer ?
    if exists('s:menus_'.bid)
        if has_key(s:menus_{bid}, key)
            let menu = s:menus_{bid}[key]
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

" Function: RestoreMenu() : Restores the entry to the "set" state.
" @post menu.state == "set"
function! s:RestoreMenu(menu)
    let isCurrent = s:IsCurrent(a:menu)
    if a:menu.state == 'non-existant' || !isCurrent
        return s:SetMenu(a:menu)
    elseif a:menu.state == 'disabled'
        return s:EnableMenu(a:menu)
    endif
endfunction

" Function: TryDefineMenu() : Fetches a menu defined by its name, priority, ...
" @post menu.state == "set"
function! s:TryDefineMenu(name, priority, mode, nore, action, silent, useenable)
    let menu = s:FindMenu(a:name, a:priority, a:mode, a:nore, a:action, a:silent, a:useenable)
    " call confirm( " New menu: ".string(menu), '&Ok', 1)
    return s:RestoreMenu(menu)
endfunction

fun! s:BufferMenu( dontremap, useenable, modes, silent, menuname, mapping )
    let noRe = a:dontremap ? 'nore' : ''
    let mll= escape(exists('maplocalleader')?maplocalleader : "\\","\\|")
    let ml = escape(exists('mapleader')     ?mapleader      : "\\","\\|")

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
        let ma=ma+1
    endwhile
endfunction

" Function: UnloadMenu() : unloads the menu-entry
" @pre menu.state == "set"
" @post menu.state == "disabled"     if menu.useenable
" @post menu.state == "non-existant" if not menu.useenable
function! s:UnloadMenu(menu)
    if a:menu.state == 'set'
        if a:menu.useenable 
            return s:DisableMenu(a:menu)
        else
            return s:UnsetMenu(a:menu)
        endif
    endif
endfunction

" Function: UnloadMenus() : unloads all the buffer-menus for the current buffer
function! s:UnloadMenus()
    let bid = bufnr('%')
    if exists('s:menus_'.bid)
        for m in values(s:menus_{bid})
            call s:UnloadMenu(m)
        endfor
    endif
endfunction

" Function: UnloadMenus() : retores all the buffer-menus for the current buffer
function! s:RestoreMenus()
    let bid = bufnr('%')
    if exists('s:menus_'.bid)
        for m in values(s:menus_{bid})
            call s:RestoreMenu(m)
        endfor
    endif
endfunction

" Autocommands to unload and restore buffer-menus
aug MRGBufferMenuEnter
    au!
    au BufEnter           * call <SID>RestoreMenus() 
    au BufLeave,BufUnload * call <SID>UnloadMenus() 
aug END

" ========================================
" Clear menus.

" Function: ClearBufferMenus() : undefines all the buffer-menus ever registered
" @param list-of-buffer-id
" @param "<buffer>" <=> current buffer
" @param nothing    <=> every buffers
function! s:ClearBufferMenus(...)
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

" ========================================
" Function: EchoMenus() : debug function
function! EchoMenus(...)
    let bid = (a:0 > 0) ? (a:1) : bufnr('%')
    if exists('s:menus_'.bid)
        echo "##[".bid." buffer's menus]\n".string(s:menus_{bid})."\n"
    endif

    echo "##[All buffer-menus]\n".string(s:menus)
    echo "##[Visible buffer-menus]\n".string(s:crt_menus)
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set ts=4 sw=4 noet fdm=indent:
