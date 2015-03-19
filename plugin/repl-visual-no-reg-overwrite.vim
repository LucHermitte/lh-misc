"=============================================================================
" File:		repl-visual-no-reg-overwrite.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/License.md>
" Version:	2.1
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
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" I haven't found how to hide this function (yet)
function! RestoreRegister()
  if &clipboard == 'unnamed'
    let @* = s:restore_reg
  elseif &clipboard == 'unnamedplus'
    let @+ = s:restore_reg
  else
    let @" = s:restore_reg
  endif
  return ''
endfunction

function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction

function! s:ReplSelect()
    echo "Register to paste over selection? (<cr> => default register: ".strtrans(@").")"
    let c = nr2char(getchar())
    let reg = c =~ '^[0-9a-z:.%#/*+~]$'
                \ ? '"'.c
                \ : ''
    return "\<C-G>".reg.s:Repl()
endfunction

" This supports "rp that permits to replace the visual selection with the
" contents of @r
xnoremap <silent> <expr> p <sid>Repl()

" Mappings on <s-insert>, that'll also work in select mode!
xnoremap <silent> <expr> <S-Insert> <sid>Repl()
snoremap <silent> <expr> <S-Insert> <sid>ReplSelect()

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
