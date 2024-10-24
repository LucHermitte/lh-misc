"=============================================================================
" File:         plugin/inc-decr-cycle.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.2.
let s:k_version = 002
" Created:      27th Jun 2020
" Last Update:  18th Sep 2024
"------------------------------------------------------------------------
" Description:
"       The plugin extends n_CTRL-X and n_CTRL-A to boolean values, and
"       other user provided cyclable texts
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim

if &cp || (exists("g:loaded_inc_decr_cycle")
      \ && (g:loaded_inc_decr_cycle >= s:k_version)
      \ && !exists('g:force_reload_inc_decr_cycle'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_inc_decr_cycle = s:k_version
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Commands and Mappings {{{1
nnoremap <silent> <c-x> :<c-u>call <sid>cycle('dec', v:count1)<cr>
nnoremap <silent> <c-a> :<c-u>call <sid>cycle('inc', v:count1)<cr>
" Commands and Mappings }}}1
"------------------------------------------------------------------------
" Functions {{{1
" Note: most functions are best placed into
" autoload/«your-initials»/«inc_decr_cycle».vim
" Keep here only the functions are are required when the plugin is loaded,
" like functions that help building a vim-menu for this plugin.
let s:k_on_off     = ['on', 'off']
let s:k_yes_no     = ['yes', 'no']
let s:k_true_false = ['true', 'false']

" TODO: support extensions
let s:k_loglevels = ['debug', 'info', 'warning', 'error', 'critical']

function! s:KeepCase(ref, new) abort
  if 1 && exists('*KeepCase')
    " Michael Geddes plugin
    return KeepCase(a:ref, a:new)
    " ELSE:
    " Using a simplified flavour that only plays with initial capital
    " letters, with cyclable word in lower case
  elseif a:ref =~ '\v^\u+$'
    " TRUE ON
    return substitute(a:new, '\v^.+$', '\U&', '')
  elseif a:ref =~ '\v^\u'
    " True Off
    return substitute(a:new, '\v^.', '\U&', '')
  else
    " Oups, case not covered yet...
    return a:new
  endif
endfunction

function! s:build_dict(dict, list) abort
  call map(copy(a:list), 'extend(a:dict, {v:val : a:list})')
endfunction

let s:repls = {}
call s:build_dict(s:repls, s:k_on_off)
call s:build_dict(s:repls, s:k_yes_no)
call s:build_dict(s:repls, s:k_true_false)
call s:build_dict(s:repls, s:k_loglevels)

function! s:replace(match, nb) abort
  let low_match = tolower(a:match)
  if  has_key(s:repls, low_match)
    let list = s:repls[low_match]
    let idx = index(list, low_match)
    return s:KeepCase(a:match, list[(idx+a:nb) % len(list)])
  else
    return eval(a:match) + a:nb
  endif
endfunction

function! s:cycle(dir, nb) abort
  let lists = s:k_on_off + s:k_yes_no + s:k_true_false + s:k_loglevels
  let patterns = '%(%('.join(map(lists, '"<".v:val.">"'), '|').'|-?\d+))'
  let within_re = '\v\c(.*%#)@='.patterns.'@>(%#.*)@<='
  let before_re = '\v\c'.patterns

  " TODO: fiw within pattern for numbers...
  let [ln, col] = searchpos(within_re, 'cz')
  if ln == 0 " Cursor not within a searched pattern
    let ln = line('.')
    let [ln2, col] = searchpos(before_re, 'czn')
    if ln2 != ln " cursor not before a searched pattern
      return
    endif
  endif
  let line1 = getline('.')
  let nb = a:dir == 'inc' ? a:nb : - a:nb
  let line11 = col > 1 ? line1[:col-2] : ''
  let line12 = line1[col-1:]
  let line22 = substitute(line12, before_re, '\=s:replace(submatch(0), nb)', '')
  call setline('.', line11.line22)
  call cursor(ln, col)
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
