" ========================================================================
" File:         ftplugin/vim_set.vim
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" Last Update:  24th Aug 2024
" Requirements: lh-vim-lib
"
" ========================================================================
" === Stuff that always need to be redefined              {{{1
" ========================================================================
" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

" }}}1
" ========================================================================
" === Buffer relative stuff                               {{{1
" ========================================================================
"if (!exists("b:loaded_vim_set_vim")) &&
"      \ !(exists("g:BuffOptions2Loaded") && exists("g:loaded_vim_set_vim"))
if exists("b:loaded_vim_set") && !exists('g:force_reload_vim_set')
  let &cpo = s:cpo_save
  finish
endif
let b:loaded_vim_set = 203

" ------------------------------------------------------------------------
" Options to be set {{{2
" ------------------------------------------------------------------------
"
setlocal comments=\:\"
setlocal notimeout
setlocal ai
setlocal smartindent
setlocal smarttab
setlocal sw=2
if &modifiable
  setlocal ff=unix
endif

" setlocal def=^function!\\=\\s*\\(s:\\)\\=

" Stuff for mu-template
let b:author_short = 'Luc Hermitte <hermitte {at} free {dot} fr>'
let b:lhvim_url    = lh#vcs#as_http(expand('%:p:h'))
let b:author       = "Luc Hermitte <EMAIL:".g:author_email.">"
if exists('b:lhvim_url') && lh#option#is_set(b:lhvim_url)
  let b:author    .= "\r" .'"'. "\<tab>\<tab><URL:".b:lhvim_url.">"
endif
"
" ------------------------------------------------------------------------
" Help init {{{2
" ------------------------------------------------------------------------
"
" Help.vim support ?
if exists("*BuildHelp")
  command! -buffer -nargs=1 VIMHelp :call BuildHelp('VIM', <q-args>)
   noremap <buffer> <C-F1> :call ShowHelp('VIM')<cr>
  inoremap <buffer> <C-F1> <ESC>:call ShowHelp('VIM')<cr>a
  call ClearHelp('VIM')
else
  command! -buffer -nargs=1 VIMHelp
endif

VIMHelp  "                      -------------------
VIMHelp  "                      V I M   M A C R O S
VIMHelp  "                      -------------------
VIMHelp  "
VIMHelp  "
VIMHelp  "  <C-F1>      This help
VIMHelp  "

" ------------------------------------------------------------------------
" Mappings {{{2
" ------------------------------------------------------------------------
"
VIMHelp  "[i  ] �i      inoremap
VIMHelp  "[i  ] �n      noremap
VIMHelp  "[i  ] �v      xnoremap
VIMHelp  "[i  ] �m      <M-><Left>
inoremap  <buffer> ]i inoremap
inoremap  <buffer> ]n noremap
inoremap  <buffer> ]v xnoremap
inoremap  <buffer> ]m <M-><Left>

VIMHelp  "[i  ] <M-c>   <<call _()<CR> >>
VIMHelp  "[i  ] <M-e>   <<exe 'normal _' >>
inoremap  <buffer> <silent> <M-c>
      \ <c-r>=lh#map#insert_seq('<m-c>', ':call !cursorhere!(!mark!)!mark!')<cr>
inoremap  <buffer> <silent> <M-e>
      \ <c-r>=lh#map#insert_seq('<m-e>', ':exe "normal! !cursorhere!"!mark!')<cr>

VIMHelp  "[i  ] <M-n>   <<normal>>
VIMHelp  "[i  ] <M-p>   <<put = '_'>>
VIMHelp  "[i  ] <M-r>   <<return>>
VIMHelp  "[i  ] <M-s>   <<source>>
inoremap  <buffer> <M-n> normal
inoremap  <buffer> <M-p>
      \ <c-r>=lh#map#insert_seq('<m-n>', "put='!cursorhere!'!mark!")<cr>
inoremap  <buffer> <M-r> return

" TODO: support multilines
xnoremap <silent><buffer> <c-l>e <c-\><c-n>:echo lh#object#to_string(<c-r>=lh#visual#selection()<cr>)<cr>gv
xnoremap <silent><buffer> <c-l>d <c-\><c-n>:debug echo <c-r>=lh#visual#selection()<cr><cr>gv
xnoremap <silent><buffer> <c-l>x <c-\><c-n>:for ___line in <sid>PrepareMultilines(lh#visual#selection()) <bar> exe ___line <bar> endfor<cr>gv

nnoremap <silent><buffer> <c-l>x :exe getline('.')<cr>

" Loads MapNoContext()
""so $VIMRUNTIME/macros/misc_map.vim

" Control statement: function {{{3
VIMHelp  "[i v] <M-f>   <<function! _() ^Mendfunction>>
"NB: there is a space before !cursorhere! with mappings and with with
"abbreviations.
inoremap  <buffer> <silent> <M-f>
      \ <C-R>=lh#map#insert_seq('<M-f>',
      \ "function! !cursorhere!(!mark!) abort\n!mark!\nendfunction!mark!")<CR>
inoreab  <buffer> <silent>  fun
      \ <C-R>=<sid>InsertIfNotAfter('fun',
      \ "function!!cursorhere!(!mark!) abort\n!mark!\nendfunction!mark!",
      \ '\S')<CR>
inoreab  <buffer> <silent>  function
      \ <C-R>=<sid>InsertIfNotAfter('function',
      \ "function!!cursorhere!(!mark!) abort\n!mark!\nendfunction!mark!",
      \ '\S')<CR>

xmap  <buffer> <silent> <M-f> <localleader>fun
xnoremap <buffer> <silent> <localleader>fun
      \ <c-\><c-n>@=lh#map#surround('function! !cursorhere!(!mark!) abort', 'endfunction',
      \ 1, 1, '``!jump-and-del!', 1, 'fun ')<cr>

" Control statement: if       {{{3
VIMHelp  "[i v] <M-i>   <<if _ ^Mendif>>
inoremap <buffer> <silent> <M-i>
      \ <C-R>=lh#map#insert_seq('<M-i>', "if !cursorhere!\nendif!mark!")<CR>
inoreab  <buffer> <silent> if
      \ <C-R>=lh#map#insert_seq('if', "if !cursorhere!\nendif!mark!")<CR>


xmap  <buffer> <silent> <M-i> <localleader>if
xnoremap <buffer> <silent> <localleader>if
      \ <c-\><c-n>@=lh#map#surround('if !cursorhere!', 'endif',
      \ 1, 1, '', 1, 'if ')<cr>

" Control statement: elif     {{{3
inoreab  <buffer> <silent> elif
      \ <C-R>=lh#map#insert_seq('elif', "elseif!cursorhere!")<CR>


xmap  <buffer> <silent> <M-i> <localleader>elif
xnoremap <buffer> <silent> <localleader>elif
      \ <c-\><c-n>@=lh#map#surround('elif !cursorhere!', '!mark!',
      \ 1, 1, '', 1, 'elif ')<cr>

" Control statement: while    {{{3
VIMHelp  "[i  ] <M-w>   <<while _ ^Mendwhile>>
inoremap <buffer> <silent> <M-w>
      \ <C-R>=lh#map#insert_seq('<M-w>', "while !cursorhere!\nendwhile!mark!")<CR>
inoreab  <buffer> <silent> wh
      \ <C-R>=lh#map#insert_seq('wh', "while!cursorhere!\nendwhile!mark!")<CR>
inoreab  <buffer> <silent> while
      \ <C-R>=lh#map#insert_seq('while', "while!cursorhere!\nendwhile!mark!")<CR>

" Control statement: for      {{{3
xmap  <buffer> <silent> <M-w> <localleader>wh
xnoremap <buffer> <silent> <localleader>wh
      \ <c-\><c-n>@=lh#map#surround('while !cursorhere!', 'endwhile',
      \ 1, 1, '', 1, 'wh ')<cr>

" vmap  <buffer> <silent> <M-f> <localleader>for
inoreab  <buffer> <silent> for
      \ <C-R>=lh#map#insert_seq('for', "for!cursorhere! in!mark!\nendfor!mark!")<CR>
xnoremap <buffer> <silent> <localleader>for
      \ <c-\><c-n>@=lh#map#surround('for !cursorhere! in !mark!', 'endfor',
      \ 1, 1, '', 1, 'for ')<cr>

" Control statement: try      {{{3
nmap <buffer> <silent> <localleader>try V<localleader>try
xnoremap <buffer> <silent> <localleader>try
      \ <c-\><c-n>@=lh#map#surround('try!cursorhere!', "finally!mark!\nendtry",
      \ 1, 1, '', 1, 'try ')<cr>

inoreab  <buffer> <silent> try
      \ <C-R>=lh#map#insert_seq('try', "try!cursorhere! \nfinally!mark!\nendtry!mark!")<CR>
" Control statements }}}3

VIMHelp  "


" }}}1
" ========================================================================
" === Global defs. like functions                         {{{1
" ========================================================================
if !exists("s:ftplugin_loaded") || exists('g:force_reload_vim_set')
  let s:ftplugin_loaded = 1

  function! s:PrepareMultilines(selection) abort
    let lines = split(a:selection, '\v'."\n".'(\s*\\)@!')
    call map(lines, 'substitute(v:val, "\\v\\n\\s*\\", "", "g")')
    return lines
  endfunction

  " MapMenu {{{2
  function! s:MapMenu(code,text,binding, tex_cmd, ...)
    let _2visual = (a:0 > 0) ? a:1 : "viw"
    call IVN_lh#menu#make(a:code, a:text.'     --  \' . a:cmd.'{}', a:binding,
          \ '\'.a:cmd.'{',
          \ '<ESC>`>a}<ESC>`<i\' . a:cmd . '{<ESC>%l',
          \ _2visual.a:binding,
          \ 0, 1, 0)
  endfunction

  " InsertIfNotAfter
  function! s:InsertIfNotAfter(key, what, pattern)
    let c = col('.') - 1
    let l = getline('.')
    let l = strpart(l, 0, c)
    if l =~ a:pattern.'\s*$'
      return a:key
    else
      return lh#map#insert_seq(a:key, a:what)
    endif
  endfunction

  " }}}2
endif " End global defs
" ========================================================================
function! Test( VAR ) " {{{2
  " Method 1 : incomplete
  ""let bb = substitute( a:VAR, "\<esc\>", "\<esc>", 'g' )

  " Method 2 : only for if-endif
  ""let aa = "esc"
  "exe 'let esc = "\<' .aa . '>"'
  "let bb = "endif" . esc . "Oif "

  " Method 3 : OK
  ""let bb = '"' . substitute( a:VAR, "\<\\(.*\\)\>", '"."\\<\1>"."', 'g' ) .  '"'
  ""exe 'let bb = '.bb
  ""exe 'return'. bb

  " Method 4 : in one line only
  exe 'return "' . substitute( a:VAR, "\<\\(.*\\)\>", '"."\\<\1>"."', "g" ).'"'
  return  substitute( a:VAR, "\<\\(.*\\)\>", '"."\\<\1>"."', "g" )
endfunction
""imap == <C-R>=Test( "endif\<esc\>Oif ")<CR>
""imap == <C-R>=Test( "endfunction\<esc\>Ofunction!()\\<Left\>\\<Left\>")<CR>

" }}}1
" ========================================================================
  let &cpo = s:cpo_save
" ========================================================================
" vim600: fdm=marker:

