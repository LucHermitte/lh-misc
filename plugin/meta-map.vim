"=============================================================================
" File:         plugin/meta-map.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Answer to:    http://vi.stackexchange.com/questions/10329/use-variable-that-depends-on-function-for-mapping-inside-vimrc
" Version:      0.0.1.
let s:k_version = 001
" Created:      18th Nov 2016
" Last Update:  18th Nov 2016
"------------------------------------------------------------------------
" Description:
"    Define `:Meta` command that maps to `<m-key>`  to `<leader>key`
"
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
if &cp || (exists("g:loaded_meta_map")
      \ && (g:loaded_meta_map >= s:k_version)
      \ && !exists('g:force_reload_meta_map'))
  finish
endif
let g:loaded_meta_map = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
" TODO: add support for command line completion...
command! -nargs=+
      \ Meta
      \ call s:Map(<f-args>)
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«meta_map».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
let s:is_meta_supported = has('nvim') || has('gui_running')

function! s:Map(how, ...)
  let cmd = a:how
  let is_key_known = 0
  for a in a:000
    if ! is_key_known && a !~ '^<\k\+>$'
      let cmd .= s:is_meta_supported ? ' <M-'.a.'>' : ' <leader>'.a
      let is_key_known = 1
    else
      let cmd .= ' '.a
    endif
  endfor
  exe cmd
endfunction
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
