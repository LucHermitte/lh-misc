" Buffer Menus - Add menus to the current buffer only.
" Initial Author: Michael Geddes <michaelrgeddes@optushome.com.au>
" Maintainer: Luc Hermitte
" Version: 1.9.3
" Initial URL: http://vim.sourceforge.net/scripts/script.php?script_id=246
" Current URL: http://github.com/LucHermitte/lh-misc -> plugin + autoload
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
" They also allow <SID> (providing you have done the
" "exe lh#buffermenu#FindBufferSID()" at the beginning of the script), and
" will expand <leader> and <localleader> in menu names.
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
" exe lh#buffermenu#FindBufferSID()
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

com! -nargs=+ -bang -complete=menu Bmenu  call lh#buffermenu#_define(<q-bang>, <f-args> )
com! -nargs=+ -bang -complete=menu Bimenu call lh#buffermenu#_define(<q-bang>, 'i', <f-args> )
com! -nargs=+ -bang -complete=menu Bvmenu call lh#buffermenu#_define(<q-bang>, 'v', <f-args> )
com! -nargs=+ -bang -complete=menu Bamenu call lh#buffermenu#_define(<q-bang>, 'a', <f-args> )
com! -nargs=+ -bang -complete=menu Bcmenu call lh#buffermenu#_define(<q-bang>, 'c', <f-args> )
com! -nargs=+ -bang -complete=menu Bnmenu call lh#buffermenu#_define(<q-bang>, 'n', <f-args> )
com! -nargs=?                  Bunmenuall call lh#buffermenu#_clear_all(<f-args>)

com! -nargs=+ -complete=menu Bnoremenu    call lh#buffermenu#_define('!', <f-args> )
com! -nargs=+ -complete=menu Binoremenu   call lh#buffermenu#_define('!', 'i', <f-args> )
com! -nargs=+ -complete=menu Bvnoremenu   call lh#buffermenu#_define('!', 'v', <f-args> )
com! -nargs=+ -complete=menu Banoremenu   call lh#buffermenu#_define('!', 'a', <f-args> )
com! -nargs=+ -complete=menu Bcnoremenu   call lh#buffermenu#_define('!', 'c', <f-args> )
com! -nargs=+ -complete=menu Bnnoremenu   call lh#buffermenu#_define('!', 'n', <f-args> )

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set ts=4 sw=4 noet fdm=indent:
