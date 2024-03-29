"=============================================================================
" File:         searchfile.vim                                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3
" Version:      0.2.4
let s:k_version = 024
" Created:      01st Feb 2006
" Last Update:  24th Mar 2022
"------------------------------------------------------------------------
" Description:  Vim plugin wrapper for searchfile.pl
"
"------------------------------------------------------------------------
" Requirements:
" - vim7+
" - lh-vim-lib v2.0.6
" - searchfile.pl
" - perl, xargs, find, grep, egrep, printf, sed
" Optional Dependencies:
" - BuildToolsWrapper (for a better :Copen)
" }}}1
"=============================================================================


"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_searchfile")
      \ && (g:loaded_searchfile >= s:k_version)
      \ && !exists('g:force_reload_searchfile')
  finish
endif
let g:loaded_searchfile = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------

command! -nargs=+
      \ -complete=customlist,SFComplete
      \ Searchfile :call s:Search(<f-args>)

nnoremap <expr> <silent> <F3>   (&diff ? "]c:call \<sid>NextDiff()\<cr>" : ":cn\<cr>")
nnoremap <expr> <silent> <S-F3> (&diff ? "[c" : ":cN\<cr>")

nnoremap <Plug>(search-word)             :<c-u>call <sid>Search(<sid>Extension(),          escape(expand('<cword>'),     '%#\\'))<cr>
xnoremap <Plug>(search-word)             :<c-u>call <sid>Search(<sid>Extension(),          escape(lh#visual#selection(), '%#\\'))<cr>
nnoremap <Plug>(search-word-interactive) :<c-u>Searchfile <c-r>=<sid>Extension()<cr> <c-r>=escape(expand('<cword>'),     '%#\\')<cr>
xnoremap <Plug>(search-word-interactive) :<c-u>Searchfile <c-r>=<sid>Extension()<cr> <c-r>=escape(lh#visual#selection(), '%#\\')<cr>

call lh#mapping#plug('<C-F3>',   '<Plug>(search-word)',             'nx')
call lh#mapping#plug('<C-S-F3>', '<Plug>(search-word-interactive)', 'nx', {'silent': 0})


" Functions {{{1

" ## Next Diff Functions {{{2
" Better ]c, [c jump

" Function: s:GotoWinline() {{{3
function! s:GotoWinline(w_l) abort
  normal! H
  while winline() < a:w_l
    normal! j
  endwhile
  " todo: beware of cases where the window is too little
endfunction

" Function: s:NextDiff() {{{3
function! s:NextDiff() abort
  if ! &diffopt =~ 'filler' | return | endif

  let ignore_blanks = &diffopt =~ 'iwhite'

  " Assert: called just after a ]c or a [c
  " Forces the cursos to be synchronized in all synced windows
  " let diff_l = line()
  try
    let foldenable = &foldenable
    set nofoldenable

    let w_l = winline() " problematic with enabled lines (from diff...)
    echomsg w_l.'|'.line('.').'|'.getline('.')

    let lines = {}
    windo if &diff | call <sid>GotoWinline(w_l) | let lines[winnr()]={'text':getline('.'), 'number':line('.')} | endif
  finally
    let &foldenable = foldenable
  endtry

  echomsg string(lines)
  if len(lines) < 2 | return | endif

  let indices = repeat([0], len(lines))
  let tLines = values(lines)
  let found = 0
  " infinite loop on two empty texts...
  while ! found
    let c = ''
    let next_idx = []
    let i = 0
    while i != len(indices)
      let crt_line = tLines[i].text
      let n = indices[i]
      if len(crt_line) == n
        let found = 1
        break
      endif

      let c2 = (len(crt_line) == n) ? 'EOL' : crt_line[n]
      if empty(c)
        let c = c2
      endif

      " checks match
      let n += 1
      if c =~ '\s'
        if (c2 != c) && (ignore_blanks && c2 !~ '\s')
          let found = 1
          break
        else " advance
          while ignore_blanks && (n == len(crt_line) || crt_line[n] =~ '\s')
            let n += 1
          endwhile
        endif
      else
        if c2 != c
          let found = 1
          break
        endif
      endif
      let next_idx += [n]

      let i += 1
    endwhile
    if found | break | endif

    let indices = next_idx
  endwhile

  " now goto the right column
  let windows = keys(lines)
  " Assert len(windows) == len(indices)
  let w = 0
  while w != len(windows)
    echomsg 'W#'.windows[w].' -> :'(tLines[w].number).'normal! '.(indices[w]+1).'|'
    exe windows[w].'wincmd w'
    silent! exe (tLines[w].number).'normal! 0'.(indices[w]).'l'
    let w += 1
  endwhile
  echomsg string(indices)
endfunction


" ## Searchfile functions {{{2

" Function: s:Extension() {{{3
runtime plugin/let.vim
LetIfUndef g:searchfile.ext.c          = 'h,c'
LetIfUndef g:searchfile.ext.cpp        = 'h,cpp,hpp,cxx,hxx'
LetIfUndef g:searchfile.ext.python     = 'py'
LetIfUndef g:searchfile.ext.markdown   = 'md'
LetIfUndef g:searchfile.ext.vim        = 'vim,txt,template'
LetIfUndef g:searchfile.ext.help       = 'vim,txt,template'
LetIfUndef g:searchfile.ext.xslt       = 'xsl,js'
LetIfUndef g:searchfile.ext.javascript = 'xsl,js'

function! s:Extension() abort
  if exists('b:searchfile_ext')    | return b:searchfile_ext
  elseif !empty(&suffixesadd)      | return join(map(split(&suffixesadd, ','), 'v:val[1:]'), ',')
  elseif &ft =~ 'xslt\|javascript' | return 'xsl,js'
  else                             | return get(g:searchfile.ext, &ft, &ft)
  endif
endfunction

" Function: s:DoSearch() {{{3
function! s:DoSearch(fileext, pattern, opt) abort
  let save_grepprg=&grepprg
  try
    let extra_opts = lh#option#get('searchfile.opts', '')
    let &grepprg = 'searchfile.pl -n -e '.a:fileext.a:opt.' '.extra_opts
    " <=> find {path} \( -name '*.h' -o -name '*.cpp' {-o prune CVS....} \)
    "       | xargs grep -n
    echo 'grep! '.a:pattern
    exe 'grep! '.a:pattern
    if exists(':Copen') " from BuildToolsWrapper
      :Copen
    else
      :copen
    endif
  finally
    let &grepprg=save_grepprg
  endtry
endfunction

" Function: s:Search() {{{3
function! s:Search(fileext, pattern, ...) abort
  let pattern = a:pattern
  if &ft =~ 'vim\|help'
    let pattern = escape(pattern, '#')
  endif
  let opt     = ''

  try
    " Sometimes the string received is �"pat_begin pat_end"�, which arrives as
    " two different parameters that need to be concatened.
    " @todo: take care of escaped quotes
    " @todo: rewrite the algorithm
    if     pattern[0] =~ '["' . "']"
      let pattern_ready = (pattern[-1:] == pattern[0])
    elseif pattern[-1:] =~ '["' . "']"
      throw "SearchFile: Unbalanced quotes in ``".a:pattern.' '.join(a:000,'').'``'
    else
      let pattern_ready = 1
    endif


    let i = 1
    while i <= a:0
      if ! pattern_ready
        let pattern .= a:{i}
        let pattern_ready = (pattern[-1:] == pattern[0])
      elseif a:{i} == '-v'
        let opt .= ' -v'
      elseif a:{i} == '-i'
        let opt .= ' -i'
      elseif a:{i} == '-x'
        let i += 1
        let opt .= ' -x '.a:{i}
      else
        let opt .= ' -p '.a:{i}
      endif
      let i += 1
    endwhile
    if ! pattern_ready
      throw "SearchFile: Unbalanced quotes in ``".a:pattern.' '.join(a:000,'').'``'
    else
      call s:DoSearch(a:fileext, pattern, opt)
    endif
  catch /^SearchFile:/
    echoerr v:exception
  endtry
endfunction

" Function: SFComplete(ArgLead, CmdLine, CursorPos) {{{3
let s:commands = 'Se\%[archfile]\>'
function! SFComplete(ArgLead, CmdLine, CursorPos) abort
  let cmd = matchstr(a:CmdLine, s:commands)
  let cmdpat = '^'.cmd

  let tmp = substitute(a:CmdLine, '\s*\S\+', 'Z', 'g')
  let pos = strlen(tmp)
  let lCmdLine = strlen(a:CmdLine)
  let fromLast = strlen(a:ArgLead) + a:CursorPos - lCmdLine
  " The argument to expand, but cut where the cursor is
  let ArgLead = strpart(a:ArgLead, 0, fromLast )
  if 0
    call confirm( "a:AL = ". a:ArgLead."\nAl  = ".ArgLead
          \ . "\nx=" . fromLast
          \ . "\ncut = ".strpart(a:CmdLine, a:CursorPos)
          \ . "\nCL = ". a:CmdLine."\nCP = ".a:CursorPos
          \ . "\ntmp = ".tmp."\npos = ".pos
          \ . "\ncmd = ".cmd
          \, '&Ok', 1)
  endif

  if cmd != 'Searchfile'
    throw "Completion option called with wrong command"
  endif

  if pos >= 4
    if a:ArgLead[0] == '-'
      return ['-i', '-x']
    else
      if ArgLead[-1:]!= '/' && isdirectory(ArgLead)
        let ArgLead .= '/'
      endif
      let dirs = split(glob(ArgLead.'*'), "\n")
      call filter(dirs, 'isdirectory(v:val)')
      return dirs
    endif
  else
    return []
  endif
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
