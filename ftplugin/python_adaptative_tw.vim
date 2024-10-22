vim9script

# =============================================================================
# File:         ftplugin/python_adaptative_tw.vim                 {{{1
# Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
#		<URL:http://github.com/LucHermitte/lh-misc>
# License:      GPLv3 with exceptions
#               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
# Version:      0.0.3.
const k_version = 003
# Created:      16th Oct 2024
# Last Update:  22nd Oct 2024
#------------------------------------------------------------------------
# Description:
#       Adapt &tw to comments and docstring
#
# Configuration:
#       The textwidth can be configured through the variables:
#       - (bpg):style.textwidth.default
#       - (bpg):style.textwidth.comment
#       - (bpg):style.textwidth.docstring
#
#------------------------------------------------------------------------
# History:
# v0.0.1: First version
#       (*) Works w/ `Q` only, compatible vim & nvim
#       (*) Automatically updated tw is too slow
# v0.0.2: Vim9 version
#       (*) Use fast adaptative version rewritten in vimscript9
# v 0.0.3:
#       (*) Auto plugin extracted
#       (*) Fix handling of col('.')==col('$') in insert mode
#       (*) Update &tw only when it changes
# Todo:
#         (*) Find a way to fill (bpg):style.textwidth.default from
#             p:&tw/b:&tw...
# }}}1
#=============================================================================

# Buffer-local Definitions {{{1
# Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_python_adaptative_tw")
      \ && (b:loaded_ftplug_python_adaptative_tw >= k_version)
      \ && !exists('g:force_reload_ftplug_python_adaptative_tw')
  finish
endif
b:loaded_ftplug_python_adaptative_tw = k_version
# Avoid local reinclusion }}}2

#------------------------------------------------------------------------
### Local settings {{{2

# Don't wrap normal code, only comments
setlocal fo-=t

### Local mappings {{{2

# # Attempt 1
# xnoremap <buffer> <silent> Q :call <sid>Reformat_visual()<cr>
# nnoremap <buffer> <silent> <expr> Q <sid>Reformat_normal()

# # Attempt 2 {{{3
import autoload 'lh/adaptative_tw.vim'
# autocommand registration {{{4
augroup WatchSyntax
  au! * <buffer>
  autocmd! CursorMoved,CursorMovedI,BufEnter <buffer> call lh#adaptative_tw#Update_tw(&ft)
augroup END


### Options {{{2
# Default values             {{{4
LetIfUndef g:style.textwidth.comment   = 79
LetIfUndef g:style.textwidth.docstring = 79
LetIfUndef g:style.textwidth.default   = &tw

#=============================================================================
# Global Definitions {{{1
# Avoid global reinclusion {{{2
if (exists("g:loaded_ftplug_python_adaptative_tw")
      \ && (g:loaded_ftplug_python_adaptative_tw >= k_version)
      \ && !exists('g:force_reload_ftplug_python_adaptative_tw'))
  finish
endif
g:loaded_ftplug_python_adaptative_tw = k_version
# Avoid global reinclusion }}}2
#------------------------------------------------------------------------
### Helper functions {{{2
## GetSNR([func_name])       {{{3
const k_SID: number = getscriptinfo({'name': expand('<sfile>')})[0].sid
const k_SNR: string = printf('<SNR>%d_', k_SID)

def GetSNR(funcname: string = ""): string
  return k_SNR .. funcname
enddef

### Attempts {{{2

## Attempt 1: map based: specialize Q {{{3
var cleanup: dict<any>
def Do_clean()
  # echomsg "restore tw"
  call cleanup.finalize()
enddef

def Reformat_visual()
  cleanup = lh#on#exit()
        \.restore('&tw')
  try
    final tw = Compute_tw(&ft)
    # echomsg 'setlocal tw=' .. tw
    exe 'setlocal tw=' .. tw
    normal! gvgq
  finally
    call cleanup.finalize()
  endtry
enddef

def Reformat_normal(): string
  cleanup = lh#on#exit()
        \.restore('&tw')
  final tw = Compute_tw(&ft)
  exe 'setlocal tw=' .. tw
  # echomsg 'setlocal tw=' .. tw
  call lh#event#register_for_one_execution_at('SafeState', 'call ' .. GetSNR('Do_clean') .. '()', 'RestoreTW1')
  return 'gq'
enddef

# }}}2
#------------------------------------------------------------------------
# }}}1
#=============================================================================
# vim600: set fdm=marker:
