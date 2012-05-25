" File:		fr-abbr.vim
" Author:	Luc Hermitte <hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim>
" Last Update:	12th feb 2003
" Purpose:	Abbréviations et corrections automatiques pour documents en
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
    return "\<esc>\<S-left>\<right>cwommunément"
  elseif prev ==? 'notamen'
    return "\<BS>\<BS>ment"
  elseif prev =~? 'pr[ée]c[ée]demen'
    return "\<BS>\<BS>ment"
  elseif prev =~? 'extr[eéè]m\+emen'
    return "\<esc>\<S-left>\<right>cwxtrêmement"
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
  " set isk += àâçéèêëîïôöüûù
  set isk+=à
  set isk+=â
  set isk+=ç
  set isk+=é
  set isk+=è
  set isk+=ê
  set isk+=ë
  set isk+=î
  set isk+=ï
  set isk+=ô
  set isk+=ö
  set isk+=ü
  set isk+=û
  set isk+=ù
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
  "iab csq  conséquence
  inoremap csq conséquence
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
  iab vav  vis-à-vis
  iab cad  c'est à dire
  iab Cad  C'est à dire
  iab Malgrè  Malgré
  iab Malgrès Malgré
  iab Malgrés Malgré
  iab Malgre  Malgré
  iab malgrè  malgré
  iab malgrès malgré
  iab malgrés malgré
  iab malgre  malgré

  inoremap ^m   même
  inoremap ^M   Même
  inoremap ^c   comme
  inoremap ^C   Comme
  iab pr   pour
  iab Pr   Pour

  " fins de mots
  ""inoremap tq<tab>   tique
  ""inoremap mt<tab>   ment
  ""inoremap tn<tab>   tion

  "===========================================================================
  " mots bien récurrents dans mon cas
  iab pb   problème
  iab Pb   Problème
  iab fn   fonction
  iab syst système
  iab ens ensemble

  inoremap vcl véhicule
  inoremap bcl boucle
  inoremap carrouf carrefour
  inoremap Carrouf Carrefour
  inoremap ctrl contrôle
  inoremap Ctrl Contrôle
  inoreab cmd commande
  inoreab cong congestion
  inoremap cpl couple
  inoremap rm<tab> remarque
  inoremap alg<tab> algorithme
  inoremap xp<tab> expérience
  inoremap Xp<tab> Expérience
  inoremap XP<tab> Expérience
  inoremap don<tab> données
  inoreab déf définition
  inoreab BA base d'apprentissage
  inoreab BAs bases d'apprentissage

  iab pex par exemple
  iab Pex Par exemple

  " neural est relatif au système nerveu. Neuronal au neurone !!!
  inoremap neura neurona
  inoremap Neura Neurona


  "===========================================================================
  " Corrections
  inoremap raffic rafic

  inoremap reseau réseau
  inoremap Reseau Réseau
  inoremap couteu coûteu

  inoremap ontrole ontrôle

  inoremap facon façon

  inoremap video vidéo
  inoremap Video Vidéo

  inoremap t <c-r>=WordIn_ment()<cr>
  inoremap permanante permanente
  inoremap Permanante Permanente

  iab LE Le
  iab LEs Les
  iab LA La
  iab tres très
  iab JE Je

  iab plsu plus
  iab Plsu Plus

  iab classifieur classificateur
  iab Classifieur Classificateur

  inoreab ,, ,

  TRIGGER "echo 'Abbréviations activées'", "echo 'Abbréviations désactivées'"
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
