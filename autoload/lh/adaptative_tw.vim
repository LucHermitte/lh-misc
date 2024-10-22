vim9script

#=============================================================================
# File:         autoload/lh/adaptative_tw.vim                     {{{1
# Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
#		<URL:http://github.com/LucHermitte/lh-misc>
# License:      GPLv3 with exceptions
#               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
# Version:      0.0.2.
const k_version = 002
# Created:      21st Oct 2024
# Last Update:  22nd Oct 2024
#------------------------------------------------------------------------
# Description:
#       Autoload plugin for adapting &tw to comments and docstring
#
#------------------------------------------------------------------------
# History:      «history»
# v 0.0.3:
#       (*) Auto plugin extracted
#       (*) Fix handling of col('.')==col('$') in insert mode
#       (*) Update &tw only when it changes
# }}}1
#=============================================================================

#------------------------------------------------------------------------
# ## Misc Functions     {{{1
# ## Exported functions {{{1

## Function: SynID(l, c)     {{{3
def SynID(l: number, c: number): string
  return synIDattr(synID(l, c, 0), "name")
enddef

## Function: Compute_tw(ft)  {{{3
def Compute_tw(ft: string): number
  var lin = line('.')

  var c = col('.')
  # if over the end of line (in insert mode), let suppose previous
  # caracter
  c -= (c == col('$')) ? 1 : 0
  final syn = SynID(lin, c)
  if syn =~? 'comment'
    return lh#ft#option#get('style.textwidth.comment', ft, &tw)
  elseif ft == 'python' && syn =~? '\vstring|^$' # Special case for docstrings
    while lin >= 1
      final line = getline(lin)
      if line =~ '\v^\s*$' | lin -= 1 | continue | endif
      if SynID(lin, col([lin, "$"]) - 1) !~? '\vString|pythonTripleQuotes'
        break
      endif
      if match(line, "\\('''\\|\"\"\"\\)") > -1
        # Assume that any longstring is a docstring
        return lh#ft#option#get('style.textwidth.docstring', ft, &tw)
      endif
      lin -= 1
    endwhile
  endif
  return lh#ft#option#get('style.textwidth.default', ft, &tw)
enddef


## Attempt 2: Update tw on syntax change when the cursor is moved {{{3
# Inspiration: https://stackoverflow.com/a/4028423/15934
# See Also:
#       The more generic https://github.com/inkarkat/vim-OnSyntaxChange
#       and https://fjcasas.es/posts/smart-textwidth-on-vim-when-writing-comments
#       But I need to detect docstrings as well...

export def Update_tw(ft: string)
  final tw = Compute_tw(ft)
  if tw != &tw
    call setbufvar('%', '&tw', tw)
  endif
enddef


#------------------------------------------------------------------------
# ## Internal functions {{{1

#------------------------------------------------------------------------
# }}}1
#------------------------------------------------------------------------
#=============================================================================
# vim600: set fdm=marker:
