"=============================================================================
" File:         plugin/fixfilename.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      0.0.2.
let s:k_version = 002
" Created:      25th May 2016
" Last Update:  03rd Nov 2016
"------------------------------------------------------------------------
" Description:
"       Have vim automagically translate filenames like "file:lnum"
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_fixfilename")
      \ && (g:loaded_fixfilename >= s:k_version)
      \ && !exists('g:force_reload_fixfilename'))
  finish
endif
let g:loaded_fixfilename = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
augroup auto_jump_to_line
  au!
  " au BufNewFile *:* echomsg "New bad file"
  " au BufCreate,BufNewFile *:* nested
  au BufNewFile,BufWinEnter *:* nested
        \ call lh#event#register_for_one_execution_at('BufEnter', function('s:FixFilename'), 'auto_jump_to_line_1', expand('<afile>:t'))
augroup END

command! -nargs=0 FixFileName :call s:FixFilename()

"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«fixfilename».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
"
" TODO: find the event that happens before BufEnter and that'll still trigger filetype detection and so on.
function! s:FixFilename() abort
  let orig = expand('%')
  let p = match(orig, ':\d')
  if p >= 0
    let file = orig[ : p-1 ]
    let lnum = orig[ p+1 : ]
    " echomsg "Fixing ".orig
    let lnum = matchstr(orig, ':\zs\d\+')
    let bnum = bufnr('%')
    call lh#buffer#jump(file, 'keepalt e')
    silent exe 'bw '.bnum
    exe lnum
    filetype detect
  endif
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
