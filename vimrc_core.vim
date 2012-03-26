" -*- vim -*-
" $Id$
" ===================================================================
" Core rules for vimrc
"
" File		: vimrc_core.vim
" Initial Author: Sven Guckes
" Maintainer	: Luc Hermitte
" Last update	: 21st Jan 2009 ($Date$)
" ===================================================================

" ===================================================================
" Runtime {{{
if version >= 600
  "set runtimepath+=$VIMRUNTIME (<=> $VIM/vim60)
  set runtimepath+=$VIM
  set runtimepath+=$HOME/vimfiles/latexSuite
else
  let g:RT_runtimepath = expand("$VIM")
endif
" }}}
" ===================================================================
" Help {{{
  runtime plugin/help.vim
  if exists("*BuildHelp")
    command! -nargs=1 VimrcHelp :call BuildHelp("vimrc", <q-args>)
     noremap <S-F1> :call ShowHelp('vimrc')<cr>
    inoremap <S-F1> <c-o>:call ShowHelp('vimrc')
    call ClearHelp("vimrc")
  else
    command! -nargs=1 VimrcHelp 
  endif
 
:VimrcHelp "			-------------------------
:VimrcHelp "			C U S T O M   M A C R O S
:VimrcHelp "			-------------------------
:VimrcHelp "
:VimrcHelp "
:VimrcHelp "
" }}}
" ===================================================================
" SETtings: {{{
" ===================================================================
" Vim Options: {{{
  set nocompatible

  set bs=2		" allow backspacing over everything in insert mode
  set ai			" always set autoindenting on
  set autowrite
  set nobackup		" do not keep a backup file, use versions instead

  set cmdheight=2
  set comments=b:#,:%,fb:-,n:>,n:)
                         "cmts df: sr:/*,mb:*,el:*/,://,b:#,:%,:XCOMM,n:>,fb:-
" set dictionary=/usr/dict/words,/local/lib/german.words
                        " english words first
  set expandtab
  set nodigraph         " use i_CTRL-K instead!
  set noequalalways     " don't resize windows after splitting or closing a window
  set noerrorbells      " damn this beep!  ;-)
  set esckeys           " allow usage of curs keys within isrt mode
  if &modifiable
  set fileformat=unix   " ALWAYS !!!!!"
  endif
  set formatoptions=cqrt
                        " Options for the "txt format" cmd ("gq")
                        " I need all those options (but 'o')!
  set isfname+={        " In order to use <c-w>f on ${FOO}/path
  set isfname+=}        " In order to use <c-w>f on ${FOO}/path
  set helpheight=0      " zero disables this.
" set helpfile=c:\\vim-4.6\\docs\\help.txt
                        " filename of the helpfile
                        " this is where I usually put it on DOS; sometimes 
                        " is required to set as the default installation 
                        " does not find it  :-(
  set hidden            " 
  set highlight=8r,db,es,hs,mb,Mr,nu,rs,sr,tb,vr,ws
                        "  highlight=8b,db,es,hs,mb,Mn,nu,rs,sr,tb,vr,ws
  set nohlsearch
                        " highlight search - show the current search pattern
                        " This is a nice feature sometimes - but it sure 
                        " can get in the way sometimes when you edit.
  set noicon            " ...
" set iconstring        " set iconstring file of icon (Sven doesn't use an icon)
  set noignorecase      " ignore the case in search patterns?  NO!
  set noinsertmode      " start in insert mode?  Naah.
  "set iskeyword=@,48-57,_,192-255,-,.
  set iskeyword+=-
                        " Add the dash ('-') and the dot ('.')
                        "                   as "letters" to "words".
                        "       iskeyword=@,48-57,_,192-255   (default)
  set joinspaces        " insert two spaces after a period with every joining 
                        " of lines.  This is very nice!
  set laststatus=2      " show status line?  Yes, always!
                        " Even for only one buffer.
  set lazyredraw        " [VIM5];  do not update screen while executing macros
  set magic             " Use some magic in search patterns?  Certainly!
  set modeline          " Allow the last line to be a modeline - useful when
                        " the last line in sig gives the preferred textwidth 
                        " for replies.
  set modelines=3
  set mousemodel=popup  " instead on extend
  set nonumber
  set nrformats-=octal
  " if version <600
    " set path=.,$VIMRUNTIME/syntax/,$VIMRUNTIME/settings/
  " else
    " set path=.,$VIMRUNTIME/syntax/,$HOME/vimfiles/ftplugin/
  " endif
                        " The list of directories to search when you specify
                        " a file with an edit command.
                        " "$VIM/syntax" is where the syntax files are.
  set report=0          " show a report when N lines were changed.
                        " report=0 thus means "show all changes"!
  set ruler             " show cursor position?  Yep!
"
" Setting the "shell" is always tricky - especially when you are
" trying to use the same vimrc on different operating systems.
" Now that vim-5 has ":if" I am trying to automate the setting:
" Look in _vimrc_nix | _vimrc_win
"  if has("unix")
"    let shell='tcsh'
"  endif
"
"
  set shiftwidth=4      " Number of spaces to use for each insertion of 
                        " (auto)indent.
  set shortmess=at      " Kind of messages to show.   Abbreviate them all!
                        " New since vim-5.0v: flag 'I' to suppress "intro 
                        " message".
  set showcmd           " Show current uncompleted command?  Absolutely!
  set showmatch         " Show the matching bracket for the last ')'?
  set showmode          " Show the current mode?  YEEEEEEEEESSSSSSSSSSS!
  set suffixes=.bak,.swp,.o,~,.class,.exe,.obj,.a
                        " Suffixes to ignore in file completion, see wildignore
  set switchbuf=useopen,split " test!
			" :cnext, :make uses thefirst open windows that
                        " contains the specified buffer
  set tabstop=8         " tabstop
" set term=rxvt
  set notextmode        " no - I am using Vim on UNIX!
  set textwidth=72      " textwidth
  set title             " Permet de voir le tit. du doc. crt. ds les XTERM
  set nottyfast         " are we using a fast terminal?
                        " seting depends on where I use Vim...
  set nottybuiltin      " 
  set ttyscroll=0       " turn off scrolling -> faster!
" set ttytype=rxvt
  set viminfo='50,<100,:1000,n~/.viminfo
                        " What info to store from an editing session
                        " in the viminfo file;  can be used at next session.
  set visualbell        "   
  set t_vb=             " terminal's visual bell - turned off to make Vim quiet!
  set whichwrap=<,>     " 
  set wildchar=<TAB>    " the char used for "expansion" on the command line
                        " default value is "<C-E>" but I prefer the tab key:
  set wildignore=*.bak,*.swp,*.o,*~,*.class,*.exe,*.obj,/CVS/,/.svn/,/.git/,*.so,*.a,*.lo,*.la,*.Plo,*.Po
  set wildmenu          " Completion on th command line shows a menu
  set winminheight=0	" Minimum height of VIM's windows opened
  set wrapmargin=1    
  set nowritebackup

  set cpoptions-=C      " enable commands that continue on the next line

" Is there a tags file? If so I'd like to use it's absolute path in case we
" chdir later
if filereadable("tags")
    " exec "set tags+=" . $PWD . "/tags"
    " $PWD => problem is there are spaces within the path name
    exec "set tags+=" . escape(expand('%:p:h'),' ') . "/tags"
endif
" }}}

" Options for differents plugins. {{{
let g:tex_flavor = 'tex'
" -- Mail_Re_set
let g:mail_tag_placement = "tag_second"
" -- EnhCommentify
let g:EnhCommentifyUseAltKeys    = "yes"
let g:EnhCommentifyRespectIndent = "yes"
"let g:EnhCommentifyFirstLineMode = "yes"
let g:EnhCommentifyPretty        = "yes"
let g:EnhCommentifyUseSyntax	 = 'yes'

" -- Michael Geddes's Buffer Menu <http://vim.sf.net/> 
let g:buffermenu_use_disable     = 1
let g:want_buffermenu_for_tex    = 2 " 0 : no, 1 : yes, 2 : global disable
                                     " cf. tex-maps.vim & texmenus.vim

" -- bracketing.base.vim <http://hermitte.free.fr/vim/>
let g:marker_select_empty_marks    = 1
let g:marker_center                = 0

" -- muTemplate
" To override in some ftplugins if required.
let g:url         = 'http://code.google.com/p/lh-vim/'
let g:author_short= "Luc Hermitte"
let g:author_email= "hermitte {at} free {dot} fr"
let g:author      = "Luc Hermitte <EMAIL:".g:author_email.">" 
" let g:author_short="Luc Hermitte <hermitte at free.fr>"
" let g:author	    ="Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>\<c-m>" .
" \ '"'. "\<tab>\<tab><URL:http://hermitte.free.fr/vim>"
imap <unique> <c-space>	<Plug>MuT_cWORD
vmap <unique> <c-space>	<Plug>MuT_Surround

" -- lhVimSpell <http://vim.sf.net/> <http://hermitte.free.fr/vim/>
let g:VS_aspell_add_directly_to_dict = 1

" -- BTW
let g:BTW_qf_position = 'bot'

" -- SearchInRuntime
let g:sir_goto_hsplit = "Hsplit"
let g:sir_goto_vsplit = "Vsplit"

" -- Johannes Zellner's Man <http://www.zellner.org/>
let g:man_vim_only = 1

" -- Yegappan Lakshmanan's grep.vim <http://vim.sf.net/> 
let Grep_key = '<F4>'
if has('win32')
  " let       Grep_Path = 'd:/users/hermitte/bin/usr/local/wbin/grep'
  " let      Fgrep_Path = 'd:/users/hermitte/bin/usr/local/wbin/fgrep'
  " let      Egrep_Path = 'd:/users/hermitte/bin/usr/local/wbin/egrep'
  " let     Agrep_Path = 'd:/users/hermitte/bin/usr/local/wbin/agrep'
  " let  Grep_Find_Path = 'd:/users/hermitte/bin/usr/local/wbin/find'
  " let Grep_Xargs_Path = 'd:/users/hermitte/bin/usr/local/wbin/xargs'
endif

" -- grep.vim
let Grep_Key = ',g'

" -- Doxygen syntax
let g:load_doxygen_syntax = 1

" -- Dr Chip Campbell's StlShowFunc
hi User1 ctermfg=white ctermbg=black guifg=white guibg=black
hi User2 ctermfg=lightblue ctermbg=black guifg=lightblue guibg=black
hi User3 ctermfg=yellow ctermbg=black guifg=lightyellow guibg=black

" -- Dr Chip Campbell's hiLink
" don't map <S-F10>'
map <Leader>hlt <Plug>HiLinkTrace

" -- William Lee's DirDiff
let g:DirDiffExcludes = '*.vba,*.rss,CVS,SunWS_cache,ir.out,.*.state,exe,bin,obj,*.o,*.os,tags,lib,.svn,html,*.a,*.so'.&wildignore
let g:DirDiffIgnore   = '$Id,$Date'
let g:DirDiffAddArgs  = "-b"

" -- VCS commands.vim
let VCSCommandDisableMappings = 1
augroup VCSCommand
  au User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr>
augroup END

" -- clang_complete
let g:clang_complete_auto = 0
set completeopt-=menu,preview
set completeopt+=menuone

" -- vim addons manager
let s:my_plugins = [
      \ 'lh-vim-lib'         ,
      \ 'lh-brackets'        ,
      \ 'build-tools-wrapper',
      \ 'lh-tags'            ,
      \ 'lh-dev'             ,
      \ 'mu-template.lh'     ,
      \ 'lh-cpp'             ,
      \ 'lh-refactor'        ,
      \ 'search-in-runtime'  ,
      \ 'system-tools'       ,
      \ 'UT'                 ,
      \ 'misc'
      \]
let g:vim_addon_manager = {}
let g:vim_addon_manager['plugin_sources'] = {}
let g:vim_addon_manager['plugin_sources']['misc'] = { 'type': 'svn', 'url': 'http://lh-vim.googlecode.com/svn/misc/trunk' }

" fun X(plugin_sources, www_vim_org, scm_plugin_sources)
fun X(plugin_sources, www_vim_org, scm_plugin_sources, patch_function, snr_to_name)
  " run default:
  call vam_known_repositories#MergeSources(a:plugin_sources, a:www_vim_org, a:scm_plugin_sources, a:patch_function, a:snr_to_name)

  " patch sources the way you like:
  " let pwd = 'to_be_defined'
  if !exists('s:pwd')
    runtime addons/vim-pwds.vim
    let s:pwd = GetPwd('googlecode')
  endif
  for k in s:my_plugins
    let a:plugin_sources[k]['username'] = join(['luc.hermitte','gmail.com'], '@')
    let a:plugin_sources[k]['password'] = s:pwd
    echomsg a:plugin_sources[k]['url']
    if a:plugin_sources[k]['url'] =~ 'svn'
      let a:plugin_sources[k]['url'] = substitute(a:plugin_sources[k]['url'], '^http\>', 'https', '')
    endif
  endfor
  " TODO: identify work place and not home place
  if $USERDOMAIN != 'TOPAZE'
    for k in keys(a:plugin_sources)
      " Convert git protocol to SSH protocol for github access
      if get(a:plugin_sources[k],'type','') == 'git'
        let a:plugin_sources[k]['url'] = substitute(a:plugin_sources[k]['url'], 'git://\(github.com\)/\(.*\)', 'git@\1:\2', '')
      endif
    endfor
  endif
endf

function! s:ActivateAddons()
  runtime addons/lh-vim-lib/autoload/lh/path.vim
  runtime addons/lh-vim-lib/autoload/lh/option.vim
  let vimfiles = lh#path#vimfiles()
  exe 'set rtp+='.vimfiles.'/addons/vim-addon-manager'
  " tell VAM to use your MergeSources function:
  let g:vim_addon_manager['MergeSources'] = function('X')
  " There should be no exception anyway
  " try
  " latex-suite stuff, only in run for latex
  if match(argv(), 'tex$') >= 0
    call vam#ActivateAddons(['vim-latex'])
  endif
  " script #3361
  call vam#ActivateAddons(['Indent_Guides'])
  call vam#ActivateAddons(['stakeholders'])
  call vam#ActivateAddons(s:my_plugins, {'auto_install' : 0})
  " pluginA could be github:YourName see vam#install#RewriteName()
  " catch /.*/
  " echoe v:exception
  " endtry
endfunction
" augroup VAM
  " au!
  " au VimEnter * call <sid>ActivateAddons()
" augroup END
call s:ActivateAddons()

"" Optionally generate helptags:
" UpdateAddon vim-addon-manager

" -- no mark ring/preview word
let g:loaded_markring = 1000
imap <unique> <m-p> <Plug>PreviewWord
nmap <unique> <m-p> <Plug>PreviewWord


" }}}

" Multi-byte support {{{
" Cf. http://vim.sourceforge.net/tips/tip.php?tip_id=246 by Tony Mechelynck
if &encoding == 'utf-8'
    setglobal fileencoding=utf-8
    " set bomb
    " set termencoding=iso-8859-15
    " set termencoding=latin2
    set fileencodings=ucs-bom,utf-8,iso-8859-15
    set nodigraph
endif

if 0
  if 0 && has("multi_byte") && (version >= 602) 
    " \ && (confirm("change encoding -> utf-8", "&Yes\n&No", 2)==1)
    set encoding=utf-8
    " set encoding=latin2
    " setglobal fileencoding=latin2
    setglobal fileencoding=utf-8
    set bomb
    set termencoding=iso-8859-15
    " set termencoding=latin2
    set fileencodings=ucs-bom,iso-8859-15,iso-8859-3,utf-8
  else
    " set encoding=iso-8859-15
    set encoding=latin1
    set termencoding=iso-8859-15
    " set fileencodings=ucs-bom,iso-8859-15,iso-8859-3,utf-8
  endif
endif "}}}

" Diff mode {{{
" always
  set diffopt=filler,context:3,iwhite
  " if $OSTYPE != 'solaris' " some flavour of diff do not support -x flag
    " let g:DirDiffExcludes='CVS,*.o,*.so,*.a,svn,.*.swp'
  " endif
" if &diff " if started in diff mode
" endif
" }}}
" }}}
" ===================================================================
" MAPpings {{{
" ===================================================================
" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")
"
" -------------------------------------------------------------------
" Adjustments {{{
" -------------------------------------------------------------------
" Don't use Ex mode, use Q for formatting
:VimrcHelp " Q : formatting key
  nnoremap Q gq
  vnoremap Q gq
  noremap  gQ Q         " Garde le mode EX disponible
"
:VimrcHelp " Y : yank till the end of the line
  noremap Y y$
" Disable the command 'K' (keyword lookup) by mapping it
" to an "empty command".  (thanks, Lawrence! :-):
" map K :<CR>
" map K :<BS>
"
:VimrcHelp "  Disable the suspend for ^Z ; call shell
" I use Vim under "screen" where a suspend would lose the
" connection to the " terminal - which is what I want to avoid.
  map <C-Z> :shell
"
:VimrcHelp " Make CTRL-^ rebound to the *column* in the previous file
  noremap <C-^> <C-^>`"
"
:VimrcHelp " Make 'gf' rebound to last cursor position (line *and* column)
  noremap gf gf`"
"
:VimrcHelp " The command {number}CTRL-G show the current buffer number, too.
" This is yet another feature that vi does not have.
" As I always want to see the buffer number I map it to CTRL-G.
" Please note that here we need to prevent a loop in the mapping by
" using the comamnd "noremap"!
  noremap <C-G> 2<C-G>

:VimrcHelp " backspace in Visual mode deletes selection
  vnoremap <BS> d

nnoremap <S-right> v<right>
inoremap <S-right> <c-o>v
vnoremap <S-right> <right>

nnoremap <S-left> v<left>
inoremap <S-left> <left><c-o>v
vnoremap <S-left> <left>

nnoremap <S-down> v<down>
inoremap <S-down> <c-o>v<down>
vnoremap <S-down> <down>

nnoremap <S-up> v<up>
inoremap <S-up> <c-o>vho<up>
vnoremap <S-up> <up>

" Non :*noremap-ings because of the dependency to homeLikeVC++.vim that maps
" <home>
nmap <S-home> v<home>
imap <S-home> <c-\><c-n>vo<home>
vmap <S-home> <home>

nmap <S-end> v<end>
imap <S-end> <c-\><c-n>v<end>
vmap <S-end> <end>

" }}}
" -------------------------------------------------------------------
" Customizing the command line {{{
" -------------------------------------------------------------------
" Valid names for keys are:  <Up> <Down> <Left> <Right> <Home> <End>
" <S-Left> <S-Right> <S-Up> <PageUp> <S-Down> <PageDown>  <LeftMouse>
"
:VimrcHelp " 
:VimrcHelp " Command line editing commands in emacs style:
:VimrcHelp "   <C-A>      : home
:VimrcHelp "   <C-F>      : right
:VimrcHelp "   <C-B>      : left
:VimrcHelp "   <ESC>b     : back word
:VimrcHelp "   <ESC>f     : forward word
:VimrcHelp "   <ESC><C-H> : <C-W>
:VimrcHelp "   <C-U>      : Clear whole line
:VimrcHelp "   <C-BS>     : Clear till the beginning of the line
  cnoremap <C-A> <Home>
  cnoremap <C-F> <Right>
  cnoremap <C-B> <Left>
  cnoremap <ESC>b <S-Left>
  cnoremap <ESC>f <S-Right>
  cnoremap <ESC><C-H> <C-W>
  cnoremap <C-U> <End><C-U>
  cnoremap <C-BS> <C-U>
" }}}
" -------------------------------------------------------------------
" My Customs mappins, windows, F-keys, etc {{{
" -------------------------------------------------------------------
"
if has("unix")
  " so $VIM/_vimrc_nix
  source <sfile>:p:h/_vimrc_nix
elseif has("win32")
  source <sfile>:p:h/_vimrc_win
endif
"
:VimrcHelp " 
:VimrcHelp " <S-F1>  : Display this help                                       [N]
" 
:VimrcHelp " <C-s>   : Save a file                                             [I+N]
  nnoremap <C-s> :update<CR>
  inoremap <C-s> <c-o>:update<CR>
  vnoremap <C-s> <c-c>:update<CR>gv
"
:VimrcHelp " <F2>    : Save a file                                             [I+N]
  nnoremap <F2> :update<CR>
  inoremap <F2> <c-o>:update<CR>
  vnoremap <F2> <c-c>:update<CR>gv
"
" ---------------------------------
" Abbrebiations pour ecrire francais
"
""so $VIMRUNTIME/../macros/words_tools.vim
""so $VIMRUNTIME/../macros/Triggers.vim
""Runtime plugin/fr-abbr.vim
""call Trigger_Function('<F3>', 'FRabbrInit', 
""  \                     expand('$VIM/settings/fr-abbr.vim') ) 
:VimrcHelp " <F3>    : Activates or desactivates mappings for french edition   [I+N]
:VimrcHelp " <C-F3>  : Reloads the French mappings dictionary                  [N]
:VimrcHelp " <S-F3>  : Split-open the French mappings dictionary               [N]
" ---------------------------------
"
:VimrcHelp " <F4>    : run grep                                                [N]
:VimrcHelp " <F5>    : toggle winaltkeys option                                [N]
   set winaltkeys=no
       map <F5> ]!wakyes!
   noremap ]!wakyes! :map <F5> ]!wakmenu!<CR>:set winaltkeys=yes<CR>
   noremap ]!wakmenu! :map <F5> ]!wakno!<CR>:set winaltkeys=menu<CR>
   noremap ]!wakno! :map <F5> ]!wakyes!<CR>:set winaltkeys=no<CR>
"
:VimrcHelp " <F6>    : capitalize the previous/current word                    [I+N]
 inoremap <F6> <c-o>gUiw
  noremap <F6> gUiw
 inoremap <S-F6> <c-o>gUiW
  noremap <S-F6> gUiW

 inoremap <C-F6> <c-o>guiw
  noremap <C-F6> guiw
 inoremap <C-S-F6> <c-o>guiW
  noremap <C-S-F6> guiW
"
:VimrcHelp " <F7>    : toggle autoindent                                       [I+N]
   set ai
if ! strlen(maparg('<F7>'))
   nnoremap <F7> :set ai!<CR>:set ai?<CR>
      imap <F7> <SPACE><ESC><F7>a<BS>
endif
"
:VimrcHelp " <F9>    : toggle on and off the bracketing shortcuts              [I+N]
:VimrcHelp " <M-F9>  : toggle on and off the use of markers with «brackets»    [I+N]
" Within common_brackets.vim :
"   call Trigger_Function('<F9>', 'Brackets', expand("<sfile>:p") )
"   call Trigger_DoSwitch('<M-F9>',':let b:usemarks=1',':let b:usemarks=0')
"
:VimrcHelp " <F10>   : EXIT                                                    [I+N]
:VimrcHelp " <S-F10> : EXIT!                                                   [I+N]
  inoremap <F10> <esc>:q<cr>
   noremap <F10> :q<cr>
  inoremap <S-F10> <esc>:q!<cr>
   noremap <S-F10> :q!<cr>
"
:VimrcHelp " <F11>   : Previous Buffer                                         [I+N]
   noremap <F11> :bprev<CR>
  inoremap <F11> <esc>:bprev<CR>
:VimrcHelp " <F12>   : Next Buffer                                             [I+N]
   noremap <F12> :bnext<CR>
  inoremap <F12> <esc>:bnext<CR>
"
:VimrcHelp " <C-Del> and <C-S-Del> Delete a whole word till its end            [I+N]
   noremap  <C-Del> dw
   noremap  <C-S-Del> dW
  inoremap <C-Del> <space><esc>ce
  inoremap <C-S-Del> <esc>lcW
"
" map <backspace>
    noremap <BS> X
  " backspace in Visual mode deletes selection
   vnoremap <BS> d

:VimrcHelp " <C-PageUp> and <C-PageDown> Go to the next/previous windows and maximize it
   nnoremap <silent> <C-PageUp> <c-w>W<c-w>_
   nnoremap <silent> <C-PageDown> <c-w>w<c-w>_

   nnoremap <silent> <Plug>ShowSyntax
	 \ :echo synIDattr(synID(line("."), col("."), 1), "name")<cr>
" }}}
" -------------------------------------------------------------------
" Make p in Visual mode replace the selected text with the specified register,
" if any
runtime macros/repl-visual-no-reg-overwrite.vim

" -------------------------------------------------------------------
" Tags Browsing macros {{{
:VimrcHelp " <M-Left> & <M-Right> works like in internet browers, but for tags [N]
nnoremap <M-Left> <C-T>
nnoremap <M-Right> :tag<cr>
:VimrcHelp " <M-up> show the current tags stack                                [N]
nnoremap <M-Up> :tags<cr>
:VimrcHelp " <M-down> go to the definition of the tag under the cursor         [N]
nnoremap <M-Down> <C-]>

nnoremap <M-C-Up> :ts<cr>
nnoremap <M-C-Right> :tn<cr>
nnoremap <M-C-Left> :tp<cr>
" Tags Browsing }}}
" -------------------------------------------------------------------
" VIM - Editing and updating the vimrc: {{{
" As I often make changes to this file I use these commands
" to start editing it and also update it:
  let vimrc=expand('<sfile>:p')
:VimrcHelp '     ,vu = "update" by reading this file                           [N]
  nnoremap ,vu :source <C-R>=vimrc<CR><CR>
:VimrcHelp "     ,ve = vimrc editing (edit this file)                          [N]
  nnoremap ,ve :call <sid>OpenVimrc()<cr>

function! s:OpenVimrc()
  if (0==strlen(bufname('%'))) && (1==line('$')) && (0==strlen(getline('$')))
    " edit in place
    exe "e ".g:vimrc
  else
    exe "sp ".g:vimrc
  endif
endfunction
" }}}
" -------------------------------------------------------------------
" Commands: {{{
if ! exists(':Make')
  command! -nargs=* -complete=file Make	cd %:p:h | make <args>
  command! -nargs=* -complete=file MAKE	cd %:p:h | make <args>
endif
command! -nargs=0 		 CD	cd %:p:h
command! -nargs=0 		 LCD	lcd %:p:h
" }}}
" -------------------------------------------------------------------
" }}}
" ===================================================================
" General Editing {{{
" ===================================================================
:VimrcHelp " 
:VimrcHelp " ;rcm    = remove <C-M>s - for those mails sent from DOS:          [C]
  cmap ;rcm %s/<C-M>$//g
"
:VimrcHelp " ,Sws    = Make whitespace visible:                                [N+V]
"     Sws = show whitespace
  nmap ,Sws :%s/ /_/g<C-M>
  vmap ,Sws :%s/ /_/g<C-M>
"
"     Sometimes you just want to *see* that trailing whitespace:
:VimrcHelp " Stws    = show trailing whitespace                                [N+V]
  nmap ,Stws :%s/  *$/_/g<C-M>
  vmap ,Stws :%s/  *$/_/g<C-M>
"
" Inserting time stamps {{{
let g:EnsureEnglishDate = 1
function! DateStamp()
  let day   = strftime("%d")
  let mod = day % 10
  if (day / 10) == 1 | let th='th'      " 11, 12, 13
  elseif mod == 1    | let th = 'st'
  elseif mod == 2    | let th = 'nd'
  elseif mod == 3    | let th = 'rd'
  else               | let th = 'th'
  endif
  if g:EnsureEnglishDate == 1
    if exists('v:lc_time')
      let v_lang = v:lc_time
    else
      let a_save = @a
      redir @a
      silent! language time
      redir END
      let v_lang = matchstr(@a, '"\%(LC_TIME=\)\=\zs[a-zA-Z.0-9_-]*\ze.*"')
      let @a = a_save
    endif
    silent! language time C
    " let m = substitute(strftime("%m"), '^0', '', '')
    " let month = strpart('jan feb mar apr may jun jul aug sep oct nov dec', 4*(m-1), 3)
  endif
  let month = strftime("%b")
  if g:EnsureEnglishDate == 1
    exe 'silent! language time '.v_lang
  endif
  let year  = strftime(" %Y")
  return day . th . ' ' . month . year
endfunction  
:VimrcHelp " ydate   = print the current date                                  [A+C]
  iab ydate <C-R>=DateStamp()<cr>
  command! -nargs=0 Ydate @=DateStamp()<cr>
:VimrcHelp " ,last   = updates the 'Last Update:' field                        [N]
    if version >= 600
      " nmap ,last 1G/\c\(last changes\=\\|last update\)\s*:\s*/e+1<CR>Cydate<ESC>
      nnoremap <silent> ,last gg
	    \\|:silent let fdsave = &foldenable
	    \\|:silent set nofoldenable
	    \\|:silent if search('\clast \(changes\=\\|update\)\s*:\s*\zs')
	    \\|:silent! normal "_Cydate<ESC>
	    \\|:endif
	    \\|:silent let &foldenable = fdsave<cr>
    else
      nmap ,last 1G/[lL][Aa][Ss][Tt] [Uu][Pp][Dd][Aa][Tt][Ee]\s*:\s*/e+1<CR>Cydate<ESC>
    endif
" }}}
"
" transforming a letter in lower case to a more open reg expr : o -> [oO]
:VimrcHelp " ,up     = o -> [oO]                                               [N]
 nnoremap ,up s[]<esc>PP~2<Right>

" -------------------------------------------------------------------
" General Editing - link to program "screen" {{{
" -------------------------------------------------------------------
"       ,Et = edit temporary file of "screen" program
  "map   ,Et :e /tmp/screen-exchange
" }}}
" -------------------------------------------------------------------
" Part 5 - Reformatting Text {{{
" -------------------------------------------------------------------
"
"  NOTE:  The following mapping require formatoptions to include 'r'
"    and "comments" to include "n:>" (ie "nested" comments with '>').
"
:VimrcHelp " ,b      = break line in commented text (to be used on a space)    [N]
" nmap ,b dwi<CR>> <ESC>
  nmap ,b r<CR>
:VimrcHelp " ,j = join line in commented text (can be used anywhere on the line)[N]
" nmap ,j Jxx
  nmap ,j Vjgq
"
:VimrcHelp " ,B      = break line at current position *and* join the next line [N]
" nmap ,B i<CR>><ESC>Jxx
  nmap ,B r<CR>Vjgq
"
:VimrcHelp " ,,,     = break current line at current column,
:VimrcHelp "           inserting ellipsis and «filling space»                  [N]
  nmap ,,,  ,,1,,2
  nmap ,,1  a...X...<ESC>FXr<CR>lmaky$o<CC-R>"<ESC>
  nmap ,,2  :s/./ /g<C-M>3X0"yy$dd`a"yP

: VimrcHelp " [N],mc = move to col number [N]
  nnoremap ,mc :<c-u>call <sid>MoveToCol()<cr>
  
function! s:MoveToCol()
  let d = v:count - col('.')
  if d > 0
    exe 'normal! '.d."i \<esc>"
  endif
endfunction
  
" }}}
" -------------------------------------------------------------------
" Useful stuff.  At least these are nice examples.  :-) {{{
" -------------------------------------------------------------------
"
:VimrcHelp " yFILE/YFILE = insert the current filename (+ extension)           [A]
  iab   yFILE <C-R>=expand("%:t:r")<cr>
  iab   YFILE <C-R>=expand("%:t")<cr>
"
:VimrcHelp " ,|      : jump to the last space before the 80th column           [N]
  map ,\| 80\|F
"
"------ center the view on the current line
:VimrcHelp "  ]].    : center the view on the current line                     [I]
   " nnoremap	].	:let vc=virtcol('.')<cr>z.:exe "normal! ".vc."\|"<cr>
   " inoremap	]].      Ø<esc>zzs
   inoremap	]].      <c-o>zz
"
"----- place le curseur au de'but du mot (lettre) sous (ou avant) le curseur
   noremap      ]!wb!	ylpmz?\<[a-zA-Z_]<CR>mx`zx`x
"-----  place dans "y <count> fois le motif @x
"
"-----  Place N fois @x dans "y
"-----  Ne deplace pas le curseur
   noremap      ]!count!	i@x<esc>a <esc>BiX<esc>/@x<CR>"ydEhmzlBx`zx
"
"------ supprime la ligne courante si elle ne contient que des blancs
"------ l'intervalle [ 	] contient un espace et une tabulation
   noremap      ]!erase!	:.g/^[ 	]*$/-j<CR>$
"
"------
" :VimrcHelp "  #      : toggle the 'number' option
"------
   set  nonu
   " noremap # :set nu!<CR>:set nu?<CR>
"
"------
:VimrcHelp "# q      : put # words between `quotes'
"------
   " map  q		]!count!]!wb!mzi`e<esc>"xdlh@ya<c-v>'<esc>w
"
""------
":VimrcHelp "
":VimrcHelp "! @@   : inserts command's result before the cursor               [N]
":VimrcHelp "! @!   - inserts the result of the command that starts after @    [N]
""EX
""EX:	Nous sommes le date@@
""EX:	Nombre de mots du fichier : @wc -c %@!
""so $VIMRUNTIME/../macros/executer.vim
"------
"
:VimrcHelp " ,t      : transposes two characters: from aXb -> bXa              [N]
 nnoremap ,t XplxhhPl
" This macros shortened by one character by
" Preben Guldberg c928400@student.dtu.dk
" map ,t XpxphXp
" map ,t xphXpxp
"
" make space move the cursor to the right - much better than a *beep*
" nmap \  l
"
"     ,E = execute line
" map ,E 0/\$<CR>w"yy$:<C-R>y<C-A>r!<C-E>
" This command excutes a shell command from the current line and
" reads in its output into the buffer.  It assumes that the command
" starts with the fist word after the first '$' (the shell prompt
" of /bin/sh).  Try ",E" on that line, ie place the cursor on it
" and then press ",E":
" $ ls -la
" Note: The command line commands have been remapped to tcsh style!!
"
:VimrcHelp " ,rev    : invert lines order                                      [N+V]
" From the vim mailing list, Bob Hiestand's solution.
 vnoremap ,rev <esc>:execute "'<,'>g/^/m" line("'<")-1<cr>
 nnoremap ,rev :execute "%g/^/m" 0<cr>
" 
:digraph oe 156
:digraph OE 140

" }}}
"
" }}}
" ===================================================================
" AutoCommands {{{
" ===================================================================
"
""source $VIMRUNTIME/../macros/let-modeline.vim

" autocmd!
" -------------------------------------------------------------------
" Syntax files 
" -------------------------------------------------------------------
" Toggle syntax coloring on/off with "__":
" nn __ mg:if has("syntax_items")<Bar>syn clear<CR>else<Bar>syn on<CR>en<CR>`g
" Note:  It works - but the screen flashes are quite annoying.  :-/
"

let g:ft_ignore_pat = 'lst'

" loads my own filetype definitions {{{
" let myfiletypefile = "$VIM/myfiletypes.vim"
let myfiletypefile = expand('<sfile>:p:h').'/myfiletypes.vim'

" Activates filetype detection
if version<600
  filetype on
endif
" }}}

" Switch syntax highlighting on, when the terminal has colors {{{
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  "set hlsearch " bof : don't like it => activation sur <F8>
  :VimrcHelp " <F8> activates or desactivates hight lighting on results from searchs
  set nohlsearch
  noremap <F8> :set hlsearch!<CR>:set hlsearch?<CR>
endif
" }}}

" Only do this part when compiled with support for autocommands. {{{
if has("autocmd")
  if version >=600
    filetype plugin indent on
  endif

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " In text files, always limit the width of text to 78 characters
    autocmd BufRead *.txt set tw=78

    " This is disabled, because it changes the jumplist.  Can't use CTRL-O to go
    " back to positions in previous files more than once.
    if 0
      " When editing a file, always jump to the last known cursor position.
      " Don't do it when the position is invalid or when inside an event handler
      " (happens when dropping a file on gvim).
      autocmd BufReadPost *
	    \ if line("'\"") > 0 && line("'\"") <= line("$") |
	    \   exe "normal! g`\"" |
	    \ endif
    endif
  augroup END

  ""source $VIMRUNTIME/settings/gz.set
  if version < 600
    source $VIMRUNTIME/mysettingfile.vim
  endif
endif " has("autocmd")
" }}}

if version < 600 " {{{
  source $VIMRUNTIME/macros/matchit.vim
endif

" Plugins
if version < 600
  Runtime! ../plugin/*.vim
" else automatic ...
endif
" }}}

" global variable used by Triggers.vim in order to determine if some echoing
" can be done or not yet.
augroup Triggers
  au VimEnter * :let g:loaded_vimrc = 1
augroup END
" As this must be done after the plugins are loaded, but before the very
" end of the vim initialization, this phase has been moved to the .gvimrc

" Folding {{{
" I use Johannes Zellner's way to do it, and some of his files
if (version >= 600) && has("autocmd") && has("folding")
    augroup folding
      au!
      au FileType * runtime fold/<amatch>-fold.vim
      au FileType * if &foldmethod != 'manual'
      \ | set foldcolumn=1 | else | set foldcolumn=0 | endif
    augroup END
endif
" }}}

" }}}

" Prédac
vnoremap <silent> µ <esc>:echo strftime('%c', lh#visual#selection())<cr>
nnoremap <silent> µ :echo strftime('%c', matchstr(getline('.'), 'FRAME \zs\d\+\ze\d\{3}'))<cr>
" ===================================================================
" Last but not least... {{{
" ===================================================================
" The last line is allowed to be a "modeline" with my setup.
" It gives vim commands for setting variable values that are
" specific for editing this file.  Used mostly for setting
" the textwidth (tw) and the "shiftwidth" (sw).
" Note that the colon within the value of "comments" needs to
" be escaped with a backslash!  (Thanks, Thomas!)
"       vim:tw=75 et sw=2 comments=\:\"
"       }}}
" ===================================================================
" vim600: set fdm=marker:
