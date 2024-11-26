" -*- vim -*-
" FILE: "C:\Documents and Settings\William Lee\vimfiles\plugin\DirDiff.vim" {{{
" LAST MODIFICATION: "Wed, 22 Feb 2006 22:31:59 Central Standard Time"
" HEADER MAINTAINED BY: N/A
" VERSION: 1.1.5
" (C) 2001-2015 by William Lee, <wl1012@yahoo.com>
" }}}

" Public Interface:
command! -nargs=* -complete=dir DirDiff       call dirdiff#DirDiff (<f-args>)
command! -nargs=0               DirDiffOpen   call dirdiff#DirDiffOpen ()
command! -nargs=0               DirDiffNext   call dirdiff#DirDiffNext ()
command! -nargs=0               DirDiffPrev   call dirdiff#DirDiffPrev ()
command! -nargs=0               DirDiffUpdate call dirdiff#DirDiffUpdate ()
command! -nargs=0               DirDiffQuit   call dirdiff#DirDiffQuit ()

" The following comamnds can be used in the Vim diff mode:
"
" \dg - Diff get: maps to :diffget<CR>
" \dp - Diff put: maps to :diffput<CR>
" \dj - Diff next: (think j for down)
" \dk - Diff previous: (think k for up)

if get(g:, 'DirDiffEnableMappings', 0)
    silent! exe 'nnoremap ' . get(g:, 'DirDiffGetKeyMap', '<Leader>dg') . ' :diffget<CR>'
    silent! exe 'nnoremap ' . get(g:, 'DirDiffPutKeyMap', '<Leader>dp') . ' :diffput<CR>'
    silent! exe 'nnoremap ' . get(g:, 'DirDiffNextKeyMap', '<Leader>dj') . ' :DirDiffNext<CR>'
    silent! exe 'nnoremap ' . get(g:, 'DirDiffPrevKeyMap', '<Leader>dk') . ' :DirDiffPrev<CR>'
endif

" Default Variables.  You can override these in your global variables
" settings.
"
" For DirDiffExcludes and DirDiffIgnore, separate different patterns with a
" ',' (comma and no space!).
"
" eg. in your .vimrc file: let g:DirDiffExcludes = "CVS,*.class,*.o"
"                          let g:DirDiffIgnore = "Id:"
"                          " ignore white space in diff
"                          let g:DirDiffAddArgs = "-w"
"
" You can set the pattern that diff excludes.  Defaults to the CVS directory
let g:DirDiffExcludes           = get(g:, 'DirDiffExcludes', "")
" This is the -I argument of the diff, ignore the lines of differences that
" matches the pattern
let g:DirDiffIgnore             = get(g:, 'DirDiffIgnore', "")
let g:DirDiffSort               = get(g:, 'DirDiffSort', 1)
let g:DirDiffWindowSize         = get(g:, 'DirDiffWindowSize', 14)
let g:DirDiffInteractive        = get(g:, 'DirDiffInteractive', 0)
let g:DirDiffIgnoreCase         = get(g:, 'DirDiffIgnoreCase', 0)
let g:DirDiffTheme              = get(g:, 'DirDiffTheme', 0)
let g:DirDiffSimpleMap          = get(g:, 'DirDiffSimpleMap', 0)
" Additional arguments
let g:DirDiffAddArgs            = get(g:, 'DirDiffAddArgs', "")
" Support for i18n (dynamically figure out the diff text)
" Defaults to off
let g:DirDiffDynamicDiffText    = get(g:, 'DirDiffDynamicDiffText', 0)

let g:DirDiffIgnoreFileNameCase = get(g:, 'DirDiffIgnoreFileNameCase', 0)

"" " Force set the LANG variable before running the C command.  Default to C.
"" " Set to "" to not set the variable.
"" let g:DirDiffForceLang       = get(g:, 'DirDiffForceLang', "C")
""
"" let g:DirDiffLangString = ""
"" if (g:DirDiffForceLang != "")
""     let g:DirDiffLangString = 'LANG=' . g:DirDiffForceLang . ' '
"" endif

" String used for the English equivalent "Files "
let g:DirDiffTextFiles        = get(g:, 'DirDiffTextFiles', "Files ")

" String used for the English equivalent " and "
let g:DirDiffTextAnd          = get(g:, 'DirDiffTextAnd', " and ")

" String used for the English equivalent " differ")
let g:DirDiffTextDiffer       = get(g:, 'DirDiffTextDiffer', " differ")

" String used for the English equivalent "Only in ")
let g:DirDiffTextOnlyIn       = get(g:, 'DirDiffTextOnlyIn', "Only in ")

" String used for the English equivalent ": ")
let g:DirDiffTextOnlyInCenter = get(g:, 'DirDiffTextOnlyInCenter', ": ")

" vim: set sw=4:
