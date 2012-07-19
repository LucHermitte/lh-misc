"=============================================================================
" File:		searchfile.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	0.0.7
" Created:	01st Feb 2006
" Last Update:	12th Dec 2007
"------------------------------------------------------------------------
" Description:	Vim plugin wrapper for searchfile.pl
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
let s:k_version = 007
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

command! -nargs=+ Searchfile :call s:Search(<f-args>)

nnoremap <unique> <expr> <silent> <F3>	(&diff ? "]c:call \<sid>NextDiff()\<cr>" : ":cn\<cr>")
nnoremap <unique><expr> <silent> <S-F3>	(&diff ? "[c" : ":cN\<cr>")
nnoremap <C-F3> :call <sid>Search(<sid>Extension(), escape(expand('<cword>'), '%#'))<cr>
vnoremap <C-F3> :call <sid>Search(<sid>Extension(), escape(lh#visual#selection(), '%#'))<cr>
nnoremap <C-S-F3> :call <sid>Search(<c-r>=string(<sid>Extension())<cr>, escape(<c-r>=string(expand('<cword>'))<cr>, '%#'))
vnoremap <C-S-F3> :call <sid>Search(<c-r>=string(<sid>Extension())<cr>, escape(<c-r>=string(lh#visual#selection())<cr>, escape('%#')))

" Functions {{{1

function! s:GotoWinline(w_l)
  normal! H
  while winline() < a:w_l
    normal! j
  endwhile
  " todo: beware of cases where the window is too little
endfunction

" Better ]c, [c jump
function! s:NextDiff()
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


" Searchfile functions {{{2
function! s:Extension()
  if exists('b:searchfile_ext')    | return b:searchfile_ext
  elseif &ft == 'c'                | return 'h,c'
  elseif &ft == 'cpp'              | return 'h,cpp,hpp'
  elseif &ft =~ 'xslt\|javascript' | return 'xsl,js'
  elseif &ft =~ 'vim\|help'        | return 'vim,txt,template'
  else                             | return &ft
  endif
endfunction

function! s:DoSearch(fileext, pattern, opt)
  let save_grepprg=&grepprg
  try 
    let &grepprg = 'searchfile.pl -n -e '.a:fileext.a:opt
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

function! s:Search(fileext, pattern, ...)
  let pattern = a:pattern
  if &ft =~ 'vim\|help'
    let pattern = escape(pattern, '#')
  endif
  let opt     = ''

  try
    " Sometimes the string received is «"pat_begin pat_end"», which arrives as
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

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
