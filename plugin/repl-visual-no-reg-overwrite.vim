"=============================================================================
" File:		repl-visual-no-reg-overwrite.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/License.md>
" Version:	2.2
" Created:	14th Nov 2008
"------------------------------------------------------------------------
" Description:
"       Provides a way to paste over the visual selection without overwriting
"       the default register with "p" and "<S-insert>".
"
"       NB:
"       - A register can be specified to select what shall be pasted over
"         -> e.g.:  "ap  will paste @a over the selection
"       - In select mode, <S-insert> waits for a register and pastes it over
"         the selection.
"       - &clipboard==unnamed & unnamedplus are taken into account
"
"------------------------------------------------------------------------
" Installation:
"       Either drop the file into {rtp}/macros/ and source it from your .vimrc,
"       or put it into {rtp}/plugin/
" History:
"       v1.0: answers <URL:http://stackoverflow.com/questions/290465/vim-how-to-paste-over-without-overwriting-register>
"       v1.1: restricted to pure visual-mode (select-mode is not impacted)
"       v2.0: Take &clipboard into account.
"       v2.1: <S-insert> have been added.
"             In visual mode, it works exactly as "p"
"             In select mode, it waits for a register and pastes it over the
"             selection
"       v2.2: Relies on v_P when starting from Vim 8.2.4881
"             Improve replacement on selection (abort, list registers...)
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" This supports "rp that permits to replace the visual selection with the
" contents of @r
if lh#has#patch('patch-8.2.4881')
  xnoremap <silent> p P
  " Mappings on <s-insert>, that'll also work in select mode!
  xnoremap <silent> <S-Insert> P

  function! s:ReplSelect() abort
    while 1
      redraw!
      echo "\rRegister to paste over selection? (<cr> => default register: ".strtrans(@")." -- '?' to list them)"
      let c = nr2char(getchar())
      if c == "\<esc>" | redraw! | return "\<Ignore>" | endif
      let reg = c =~ '^[0-9a-z:.%#/*+~?]$'
            \ ? '"'.c
            \ : ''
      if reg == '"?' | registers | call getchar() | redraw!
      else           | break
      endif
    endwhile
    return "\<C-G>".reg."P"
  endfunction

else
  xnoremap <silent> <expr> p <sid>Repl()
  " Mappings on <s-insert>, that'll also work in select mode!
  xnoremap <silent> <expr> <S-Insert> <sid>Repl()

  " I haven't found how to hide this function (yet)
  function! RestoreRegister() abort
    if &clipboard == 'unnamed'
      let @* = s:restore_reg
    elseif &clipboard == 'unnamedplus'
      let @+ = s:restore_reg
    else
      let @" = s:restore_reg
    endif
    return ''
  endfunction

  function! s:Repl() abort
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
  endfunction

  function! s:ReplSelect() abort
    while 1
      redraw!
      echo "\rRegister to paste over selection? (<cr> => default register: ".strtrans(@")." -- '?' to list them)"
      let c = nr2char(getchar())
      if c == "\<esc>" | redraw! | return "\<Ignore>" | endif
      let reg = c =~ '^[0-9a-z:.%#/*+~?]$'
            \ ? '"'.c
            \ : ''
      if reg == '"?' | registers | call getchar() | redraw!
      else           | break
      endif
    endwhile
    return "\<C-G>".reg.s:Repl()
  endfunction
endif

snoremap <silent> <expr> <S-Insert> <sid>ReplSelect()

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
