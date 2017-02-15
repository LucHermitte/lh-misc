" example -> VIM: let b:toto="foo" g:tata=4 g:egal="t=y".&tw
" ===========================================================================
" File:         plugin/let-modeline.vim {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-misc>
" URL: http://github.com/LucHermitte/lh-misc/tree/master/plugin/let-modeline.vim
" Version:      1.11
" Last Update:  15th Feb 2017
"
" Purpose:                        {{{2
"       Defines the function : FirstModeLine() that extends the VIM modeline
"       feature to variables. In VIM, it is possible to set options in the
"       first and last lines.  -> :h modeline
"       The function proposed extends it to 'let {var}={val}' affectations.
"
" Exemples Of Useful Aplications: {{{2
" Typical Example:          {{{3
" When editing a LaTeX document composed of several files, it is very
" practical to know the name of the main file whichever file is edited --
" TKlatex does this thanks the global variable g:TeXfile. Hence it knows
" that latex should be called on this main file ; aux2tags.vim could also
" be told to compute the associated .aux file.
" Anyway. Defining (through menus or a let command) g:TeXfile each time is
" really boring. It bored me so much that I programmed a first version of
" this script. In every file of one of my projects I added the line :
"       % VIM: let g:TeXfile=main.tex
" [main.tex is the name of the main file of the project]
" Thus, I can very simply call LaTeX from within VIM without having to
" wonder which file is the main one nor having to specify g:TeXfile each
" time.
"
" Using Callback Functions: {{{3
" Actually, in order to affect g:TeXfile, I have to call another function.
" Hence, I define a callback function (in my (La)TeX ftplugin) that checks
" whether I want to set g:TeXfile. In that case, the callback function
" calls the right function and return true. Otherwise, it returns false.
" You will find the code of this precise callback function as an example at
" the end of this file.
"
" Tune C Compilations:      {{{3
" An easy way to tune the parameters of the compilation of simple programs
" without having to maintain a makefile:
" // VIM: let $CPPFLAGS='-I../../libs':
"
" ---------------------------------------------------------------------------
" Format:                         {{{2
"       On the _first_ line of any file, the extended modeline format is:
"               {line}          ::= [text]{white}VIM:[white]let{affectations}
"               {affectations}  ::= {sgl_affect.}
"               {affectations}  ::= {sgl_affect.}{white}{affectations}
"               {sgl_affect.}   ::= {variable}[white]=[white]{value}
"               {variable}      ::= cf. vim variable format ; beware simple
"                                   variables (other than global-, buffer-,
"                                   or window-variables) are not exported.
"                                   Can also be an environment variable -> $VAR.
"               {value}         ::= string or numeral value : no function
"                                   call allowed.
"
" Options:         {{2
"       (*) 'modeline' : vim-option that must be set to 1
"       (*) 'modelines': vim-option corrsponding to the number of lines
"                        searched.
"       (*) b:ModeLine_CallBack(var,val) : callback function
"           Enable to define callback functions when needed.  cf. lhlatex.vim
"
" Installation:                   {{{2
"       (*) Drop the file into your {rtp}/plugin/ folder.
"           And autoload/lh/let-modeline.vim accordingly
"
" Remarks:                        {{{2
"       (*) The only way to call a function is through the callback feature.
"           Affectation like 'let g:foo="abc".DEF()' are recognized and
"           forbiden.
"       (*) The modeline is recognized thanks to "VIM" in that *must* be in
"           uppercase letters
"
" Changes:                        {{{2
"       v2.0.0  Move functions to autoload plugin
"               Restore command, named `:LetModeLine` this time
"       v1.10   Code simplified, lh-vim-lib 3.5.0 required
"       v1.9:   @/ is preserved
"       v1.8:   autocommands moved to the plugin
"       v1.7:   Optimizations
"       v1.6:   Support for environment variables.
"               vim 6.x only
"               Doesn't check into folded lines anymore
"       v1.5:   Check that the format of the variables and values is correct
"               before it tries to set the variables -> no more error messages
"               when using 2html.vim.
"       v1.4:   With Vim 6.x, it doesn't mess anymore with the search history
"       v1.3:   Parse several lines according to &modelines and &modeline
"       v1.2:   no-reinclusion mecanism
"       v1.1b:  extend variable names to accept underscores
"
" Todo:                           {{{2
"       (*) Enforce the patterns and the resulting errors
"       (*) Permit to have comments ending characters at the end of the line.
"       (*) Simplify the regexps
"
" }}}1
" ===========================================================================
" Definitions: {{{1
if exists("g:loaded_let_modeline") && ! exists('g:force_reload_let_modeline') | finish | endif
let g:loaded_let_modeline = 1

" Internal function dedicated searching the matching lines {{{2
" let s:modeline_pat = '[vV][iI][mM]\d*:\s*let\s*\zs.*$'
let s:modeline_pat = '[vV][iI][mM]\d*:\s*let\zs.*$'
function! s:Do_it_on_range(first, last) abort
  if &verbose >= 2 " {{{
    echo "\n->"a:first.','.a:last. 'g/'.s:modeline_pat.
          \ '/:call lh#let_modeline#_parse_line(matchstr(getline("."),"'.
          \ escape(s:modeline_pat, '\\') .'"))'
  endif " }}}

  let lines = getline(a:first, a:last)
  call filter(lines, 'v:val =~ s:modeline_pat')
  call map(lines, 'matchstr(v:val, s:modeline_pat)')
  for line in lines
    call lh#let_modeline#_parse_line(line)
  endfor
endfunction

" The main function {{{2
function! s:FirstModeLine() abort
  if !&modeline | return | endif
  let pos = exists('getcurpos') ? getcurpos() : getpos('.')
  let e1 = 1+&modelines-1
  let b2 = line('$') - &modelines+1
  " call confirm('e1='.e1."\nb2=".b2, '&ok', 1)
  if e1 >= b2
    call s:Do_it_on_range(1,  line('$'))
  else
    call s:Do_it_on_range(1,  e1)
    call s:Do_it_on_range(b2, line('$'))
  endif
  if !exists('b:this_is_new_buffer')
    call setpos('.', pos)
  else
    unlet b:this_is_new_buffer
  endif
  " call confirm('fini!', '&ok', 1)
endfunction

" }}}2

" command {{{2
command! -nargs=0 LetModeLine call s:FirstModeLine()

" autocommand {{{2
aug LetModeline
  au!
  au BufReadPost * call s:FirstModeLine()

  " To not interfere with Templates loaders
  " au BufNewFile * :let b:this_is_new_buffer=1
  " Modeline interpretation
  " au BufEnter * :call FirstModeLine()
aug END


" }}}1
" ===========================================================================
" Example of a callback function {{{1
" Version I use in my (La)TeX ftplugin
if 0

  let b:ModeLine_CallBack = "TeXModeLine_CallBack"
  function! TeXModeLine_CallBack(var,val)
    if match(a:var, "g:TeXfile") != -1
      " restore quotes around the file name
      "let valu  = substitute( valu, '^"\=\([[:alnum:].]\+\)"\=$', '"\1"', '' )
      call TKSetTeXfileName( 2, a:val )
      return 1
    else
      return 0
    endif
  endfunction

endif
" }}}1
" ===========================================================================
" vim600: set fdm=marker:
