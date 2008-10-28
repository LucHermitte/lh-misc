" myfiletypefile
" ====================

" Vim template
" au BufNewFile,BufRead template/template.*,template/*/template.* set ft=template
au BufNewFile,BufRead *.template  | 
       \ if (expand('<afile>:p:h') =~? '.*\<template\%([/\\].\+\)\=')  |
       \    let s:ft = matchstr(expand('<afile>:p:h'), 
       \        '.*\<template[/\\]\zs[^/\\]\+')                        |
       \    if strlen(s:ft)                                            |
       \      exe 'set ft='.s:ft                                       |
       \    else                                                       |
       \      exe ("doau filetypedetect BufRead " . expand("<afile>")) |
       \    endif                                                      |
       \    let g:ft = &ft  |
       \    set ft=template |
       \ endif

" ASX movies list files
au BufNewFile,BufRead *.asx set ft=asx

" Vim settings
au BufNewFile,BufRead *.set,*.switch set ft=vim

" LaTeX settings
au BufNewFile,BufRead *.ldf,*.cls,*.ins set ft=tex

" PHP3 & PHP4
au BufNewFile,BufRead *.incl,*.php4 set ft=php

" HTML ; .html.fr for instance
au BufNewFile,BufRead *.html.?? set ft=html

" PCGen .lst files
au BufNewFile,BufRead *.lst,*.pcc set ft=pcgen

" xnews files
au BufNewFile,BufRead __* 
       \ if expand('<afile>:p:h') =~? '\<xnews\>' |
       \   let g:aliases_file = '' |
       \   set ft=mail |
       \ endif

" UML speed files
au BufNewFile,BufRead *.ums setf umlspeed

" ATV's fcf files
au BufNewFile,BufRead *.fcf set ft=dosini
