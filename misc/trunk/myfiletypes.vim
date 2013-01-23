" myfiletypefile
" ====================

" GCov files:
au BufNewFile,BufRead *.gcov set ft=gcov

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

" QPEC extensions:
au BufNewFile,BufRead *.ce,*.cty,*.cct set ft=c

" OTB C++ file extensions:
au BufNewFile,BufRead *.cxx,*.txx,*.hxx set ft=cpp
