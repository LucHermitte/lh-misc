if exists('g:swap_word_loaded') 
  finish 
endif
let g:swap_word_loaded = 1

" ======================================================================
" Tip #329 -> gw
  nnoremap <silent> gw "_yiw:s/\(\%#\w\+\)\(\W\+\)\(\w\+\)/\3\2\1/<cr><c-o><c-l>
  nnoremap <silent> gW "_yiw:s/\(\w\+\)\(\W\+\)\(\%#\w\+\)/\3\2\1/<cr><c-o><c-l>

  nnoremap <silent> gs "_yiw:s/\(\%#\k\+\)\(.\{-}\)\(\k\+\)/\3\2\1/<cr><c-o><c-l>
  nmap     <silent> gS "_yiw?\k?<cr>gs

" Then when you put the cursor on or in a word, press "gw", and 
" the word will be swapped with the next word.  The words may 
" even be separated by punctuation (such as "abc = def"). 
" gW will swap with previous word.

" While we're talking swapping, here's a map for swapping characters: 

  nnoremap <silent> gc    xph 

" This hint was formed in a collaboration between 
" Chip Campbell - Arun Easi - Benji Fisher
"
" ======================================================================
" Tip #470 : Piet Delport & Anthony (ad_scriven)
  vnoremap <silent> g" <esc>:call <sid>SwapVisualWithCut()<cr>

  function! s:SwapVisualWithCut()
    normal! `.``
    if line(".")==line("'.") && col(".") < col("'.")
      let c = col('.')
      normal! gvp```]
      let c = col('.') - c
      normal! ``
      :silent call cursor(line("."),col(".")+c)
      normal! P
    else
      normal! gvp``P
    endif
  endfunction
