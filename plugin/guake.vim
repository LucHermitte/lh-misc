"=============================================================================
" File:         plugin/guake.vim                                  {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
" Version:      0.0.1.
let s:k_version = 001
" Created:      16th Oct 2018
" Last Update:  16th Oct 2018
"------------------------------------------------------------------------
" Description:
"       Toggle terminal windows
"       https://old.reddit.com/r/vim/comments/9omv3n/popup_terminal_guakelike/
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_guake")
      \ && (g:loaded_guake >= s:k_version)
      \ && !exists('g:force_reload_guake'))
  finish
endif
let g:loaded_guake = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Options {{{1
" guake.placement = vert, botright, topleft...

" Commands and Mappings {{{1
call lh#mapping#plug('<F21>', '<Plug>(guake-toggle)', 'nt')
nnoremap <silent> <Plug>(guake-toggle) :<c-u>call <sid>toggle()<cr>
tnoremap <silent> <Plug>(guake-toggle) <c-w>:<c-u>call <sid>toggle()<cr>

" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«guake».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
function! s:toggle() abort
  " TODO: there shall be only one "guake window"
  let term_bufs = filter(range(1, bufnr('$')), 'getbufvar(v:val, "&buftype") == "terminal"')
  if empty(term_bufs)
    exe get(g:, 'guake_placement', 'botright').' term'
  else
    let term_wins = map(copy(term_bufs), 'bufwinnr(v:val)')
    call filter(term_wins, 'v:val >= 0')
    if empty(term_wins)
      exe get(g:, 'guake_placement', '').' sb '.term_bufs[0]
    else
      exe 'close '.term_wins[0]
    endif
  endif
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
