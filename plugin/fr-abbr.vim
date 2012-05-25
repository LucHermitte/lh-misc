" File:		fr-abbr.vim
" Author:	Luc Hermitte <hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim>
" Last Update:	12th feb 2003
" Purpose:	Abbr�viations et corrections automatiques pour documents en
" 		francais.
" Dependencies: words_tools.vim & Triggers.vim
"
"===========================================================================
"
"**********************************************************************
"* Loading and triggering stuff
"**********************************************************************
"
if !exists("g:FRupdateLoaded")
  let g:FRupdateLoaded = 1

  " let s:this = $VIM . '/plugin/fr-abbr.vim'
  if !exists('*Trigger_RebuildFile')
    if exists(':runtime')
      runtime macros/Triggers.vim plugin/Triggers.vim
    elseif exists(':Runtime')
      Runtime macros/Triggers.vim plugin/Triggers.vim
    elseif filereadable(expand('<sfile>:p:h').'/Triggers.vim')
      so <sfile>:p:h/Triggers.vim
    endif
  endif
  if exists('*Trigger_RebuildFile')
    let s:s_this = expand("%:p")
    function! FRupdate()
      unlet g:FRupdateLoaded
      exe "so " . s:s_this
      call Trigger_RebuildFile( 'FRabbrInit', s:s_this )
    endfunction
  else
    command! -nargs=+ TRIGGER :echo "<args>" 
  endif
  

"===========================================================================
" complete/expand some words/abbreviation that end with 't'
function! WordIn_ment()
  let prev = GetPreviousWord()
  ""echo '-'.prev . "-\n"
    ""let i = input('1')
  if prev =~? 'm$'
    return "ent"
  elseif prev ==? 'communemen'
    return "\<esc>\<S-left>\<right>cwommun�ment"
  elseif prev ==? 'notamen'
    return "\<BS>\<BS>ment"
  elseif prev =~? 'pr[�e]c[�e]demen'
    return "\<BS>\<BS>ment"
  elseif prev =~? 'extr[e��]m\+emen'
    return "\<esc>\<S-left>\<right>cwxtr�mement"
  elseif prev ==? 'incidamen'
    return "\<BS>\<BS>\<BS>\<BS>emment"
  elseif prev ==? 'cpd'
    return "\<BS>\<BS>ependant"
  elseif prev ==? 'cpd'
    return "\<BS>endant"
  elseif prev ==? 'sv'
    return "\<BS>ouvent"
  else 
    return "t"
  endif
endfunction

"===========================================================================
function! FRisk()
  " set isk += ��������������
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
  set isk+=�
endfunction

function! FRabbrInit()
  let s_isk = &isk
  call FRisk()
  " Liaisons
  iab cpdt cependant
  iab Cpdt Cependant
  iab pdt  pendant
  iab Pdt  Pendant
  iab qd   quand
  iab Qd   Quand
  iab dc   donc
  iab Dc   Donc
  "iab csq  cons�quence
  inoremap csq cons�quence
  iab lrsq lorsque
  iab ds   dans
  iab Ds   Dans

  " Mots courants
  inoremap  qq   quelque
  iab plrs  plusieurs
  iab Plrs  Plusieurs
  iab mq    manque
  iab qcq   quelconque
  iab chq   chaque
  iab Chq   Chaque
  iab chq1  chacun
  iab Chq1  Chacun
  iab tjrs  toujours
  iab svt   souvent
  iab suiv  suivant
  iab ssi   si et seulement si
  iab parmis parmi
  iab Parmis Parmi
  ""inoremap tt<tab>    tout
  ""inoremap ts<tab>    tous
  iab chx   choix
  iab vav  vis-�-vis
  iab cad  c'est � dire
  iab Cad  C'est � dire
  iab Malgr�  Malgr�
  iab Malgr�s Malgr�
  iab Malgr�s Malgr�
  iab Malgre  Malgr�
  iab malgr�  malgr�
  iab malgr�s malgr�
  iab malgr�s malgr�
  iab malgre  malgr�

  inoremap ^m   m�me
  inoremap ^M   M�me
  inoremap ^c   comme
  inoremap ^C   Comme
  iab pr   pour
  iab Pr   Pour

  " fins de mots
  ""inoremap tq<tab>   tique
  ""inoremap mt<tab>   ment
  ""inoremap tn<tab>   tion

  "===========================================================================
  " mots bien r�currents dans mon cas
  iab pb   probl�me
  iab Pb   Probl�me
  iab fn   fonction
  iab syst syst�me
  iab ens ensemble

  inoremap vcl v�hicule
  inoremap bcl boucle
  inoremap carrouf carrefour
  inoremap Carrouf Carrefour
  inoremap ctrl contr�le
  inoremap Ctrl Contr�le
  inoreab cmd commande
  inoreab cong congestion
  inoremap cpl couple
  inoremap rm<tab> remarque
  inoremap alg<tab> algorithme
  inoremap xp<tab> exp�rience
  inoremap Xp<tab> Exp�rience
  inoremap XP<tab> Exp�rience
  inoremap don<tab> donn�es
  inoreab d�f d�finition
  inoreab BA base d'apprentissage
  inoreab BAs bases d'apprentissage

  iab pex par exemple
  iab Pex Par exemple

  " neural est relatif au syst�me nerveu. Neuronal au neurone !!!
  inoremap neura neurona
  inoremap Neura Neurona


  "===========================================================================
  " Corrections
  inoremap raffic rafic

  inoremap reseau r�seau
  inoremap Reseau R�seau
  inoremap couteu co�teu

  inoremap ontrole ontr�le

  inoremap facon fa�on

  inoremap video vid�o
  inoremap Video Vid�o

  inoremap t <c-r>=WordIn_ment()<cr>
  inoremap permanante permanente
  inoremap Permanante Permanente

  iab LE Le
  iab LEs Les
  iab LA La
  iab tres tr�s
  iab JE Je

  iab plsu plus
  iab Plsu Plus

  iab classifieur classificateur
  iab Classifieur Classificateur

  inoreab ,, ,

  TRIGGER "echo 'Abbr�viations activ�es'", "echo 'Abbr�viations d�sactiv�es'"
  let &isk = s_isk
endfunction

"===========================================================================
  if exists('*Trigger_Function')
    call Trigger_Function('<leader>a', 'FRabbrInit', expand('<sfile>:p'), 0, 0 ) 
    if &cmdheight < 2
      " because of the echo... Don't show it
      imap <F3> <SPACE><ESC><leader>aa<BS>
    else
      " Have the room the show the echo
      imap <F3> <C-O><leader>a
    endif

    " <C-F3> reload the abbreviations
    " nnoremap <C-F3> :call FRupdate()<CR>
    " exe "nnoremap <S-F3> :sp ".expand("<sfile>:p")."\<CR>"
  endif
  
endif
