"=============================================================================
" File:         vimrc_coc.vim                                     {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-misc/blob/master/License.md>
" Version:      0.0.1.
let s:k_version = 001
" Created:      23rd Feb 2024
" Last Update:  23rd Feb 2024
"------------------------------------------------------------------------
" Description:
"       Where I store all my CoC related mappings, menus...
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
  function! s:coc_configure_and_start() abort
    let g:coc_user_config = {}
    let g:coc_user_config['suggest.noselect'] = v:true
    " let g:coc_user_config['suggest.enablePreselect'] = v:false
    let g:coc_user_config['coc.preferences.jumpCommand'] = ':SplitIfNotOpen4COC'
    " let g:coc_user_config['tsserver.trace.server'] = 'verbose'

    let g:coc_user_config['pyright.inlayHints.variableTypes'] = v:false
    " As &shellredir isn't set yet in the .vimrc (see :h starting), we need to
    " delay the execution of |system()| till after these options has been set.
    " That's where |VimEnter| autocommand helps.
    " Here, system() is indirectly called through lh#cpp#tags#compiler_includes()
    if executable('clangd')
        " coc-clangd takes care of everything!
        " TODO: Enable tidy from vimrc...
      " let g:coc_user_config['languageserver'] = {
      "       \     'clangd': {
      "       \         'command': 'clangd',
      "       \         'filetypes': ['c', 'cpp', 'objc', 'objcpp'],
      "       \         'rootPatterns': ['compile_flags.txt', 'compile_commands.json', '.vim/'] + g:local_vimrc + g:lh#project.root_patterns,
      "       \     }
      "       \ }
    elseif executable('ccls') && executable('clang++')
      let g:coc_user_config['languageserver'] = {
            \ 'ccls': {
            \     'command': 'ccls',
            \     'filetypes': ['c', 'cpp', 'objc', 'objcpp'],
            \     'rootPatterns': ['.ccls', 'compile_commands.json', '.vim/'] + g:local_vimrc + g:lh#project.root_patterns,
            \     'initializationOptions': {
            \         'cache': {'directory': lh#option#get('lh.tmpdir', lh#string#or($TMPDIR, '/tmp'))},
            \         'index': {'threads': 2},
            \         'clang': {'extraArgs': map(copy(lh#cpp#tags#compiler_includes('clang++')), '"-isystem".v:val') + ['-std=c++20']}
            \         }
            \     }
            \ }
      " \     'args' : ['-log-file='.lh#option#get('lh.tmpdir', lh#string#or($TMPDIR, '/tmp')).'/ccls.log','-v=1'],
      " \     'trace.server': 'verbose',
    endif
    " Workaround bug 659 to launch gvim forked
    "   Required to permit gvim to fork on launch
    "   https://github.com/neoclide/coc.nvim/issues/659
    CocStart
  endfunction

  let g:coc_start_at_startup = 0
  augroup COCGroup
    autocmd!
    " Required to permit gvim to fork on launch
    " https://github.com/neoclide/coc.nvim/issues/659
    autocmd VimEnter * call s:coc_configure_and_start()
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    " Highlight action triggers requests for a feature I'm not interreted in.
    " Moreover, it messes mark.vim
    " au CursorHold * sil call CocActionAsync('highlight')
    au CursorHoldI * sil call CocActionAsync('showSignatureHelp')
  augroup end


  " Use tab for trigger completion with characters ahead and navigate.
  " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
  inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
        " \ coc#pum#visible() ? coc#_select_confirm() :
  inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<C-n>"
  inoremap <expr> <C-N>   pumvisible() ? "\<C-p>" : "\<C-n>"
  inoremap <expr> <C-P>   pumvisible() ? "\<C-n>" : "\<C-p>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
  endfunction

  " Use <C-Space> to trigger completion.
  " <c-s-space> is used by mu-template
  inoremap <silent><expr> <C-space> coc#refresh()

  """ Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
  """ Coc only does snippet and additional edit on confirm.
  function! s:coc_cr() abort
    " Option 1: condensed
    return coc#pum#visible() && coc#pum#info().index >= 0 ? coc#_select_confirm()
          \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    " Option 2: to debug
    let g:debug_last_cr = {}
    if coc#pum#visible()
      let info = coc#pum#info()
      let has_selected = info.index >= 0
      let g:debug_last_cr["info"] = info
      let g:debug_last_cr["has_selected"] = has_selected
      if !has_selected
        return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      else
        return coc#_select_confirm()
      endif
    else
      return "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    endif
  endfunction
  inoremap <silent><expr> <Plug>VimrcCR <sid>coc_cr()
  imap <silent> <cr> <Plug>VimrcCR
  " TODO: check how it's would interact with lh-brackets (add newline
  " between brackets)... it seems OK

  " Use `[g` and `]g` to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  let s:coc_prio = '500.120.'
  let s:coc_menu = '&Plugin.&COC.'

  " Remap keys for gotos
  call lh#menu#make('n', s:coc_prio.'10', s:coc_menu.'&Goto Definition',     'gd',  '<Plug>(coc-definition)')
  call lh#menu#make('n', s:coc_prio.'20', s:coc_menu.'T&ype Definition',     '<leader>gt',  '<Plug>(coc-type-definition)')
  call lh#menu#make('n', s:coc_prio.'30', s:coc_menu.'Goto &Implementation', '<leader>gi',  '<Plug>(coc-implementation)')
  call lh#menu#make('n', s:coc_prio.'40', s:coc_menu.'Goto &References',     '<leader>gr',  '<Plug>(coc-references)')
  amenu 50.120.99 &Plugin.&COC.--<sep>-- <Nop>

  " Use K to show documentation in preview window
  nnoremap <silent> <leader>K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif CocAction('hasProvider', 'hover')
      call CocActionAsync('doHover')
    else
      call feedkeys('K', 'in')
    endif
  endfunction

  " Highlight symbol under cursor on CursorHold
  " autocmd CursorHold * silent call CocActionAsync('highlight')

  " Remap for rename current word
  call lh#menu#make('n', s:coc_prio.'100', s:coc_menu.'Re&Name',            '<leader>xr',  '<Plug>(coc-rename)')

  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  call lh#menu#make('nx', s:coc_prio.'120', s:coc_menu.'Code &Action on selection',    '<c-x>a',  '<Plug>(coc-codeaction-selected)')
  call lh#menu#make('n',  s:coc_prio.'121', s:coc_menu.'Code &Action on cursor',       '<c-x>a.', '<Plug>(coc-codeaction-selected)')
  call lh#menu#make('n',  s:coc_prio.'130', s:coc_menu.'Code &Action on current line', '<c-x>aa', '<Plug>(coc-codeaction-line)')
  call lh#menu#make('n',  s:coc_prio.'131', s:coc_menu.'Code &Action',                 '<c-x>A',  '<Plug>(coc-codeaction)')
  call lh#menu#make('n',  s:coc_prio.'131', s:coc_menu.'Code &Action on whole buffer', '<c-x>%',  '<Plug>(coc-codeaction-source)')

  " Apply reformat on selected region/test-object
  call lh#menu#make('xn', s:coc_prio.'110', s:coc_menu.'F&ormat selection',            '<c-x>=',  '<Plug>(coc-format-selected)')

  " Apply autofix on current line
  call lh#menu#make('n',  s:coc_prio.'140', s:coc_menu.'Auto Fi&x current line',       '<c-x>qf', '<Plug>(coc-fix-current)')
  call lh#menu#make('n',  s:coc_prio.'150', s:coc_menu.'Refactor',                     '<c-x>r%', '<Plug>(coc-codeaction-refactor)')
  call lh#menu#make('nx', s:coc_prio.'151', s:coc_menu.'&Refactor on Selection',       '<c-x>rf', '<Plug>(coc-codeaction-refactor-selected)')

  " Run the Code Lens action on the current line
  call lh#menu#make('n',  s:coc_prio.'160', s:coc_menu.'Code &Lens on current line',   '<c-x>cl', '<Plug>(coc-codelens-actions)')

  " Requires 'textDocument/selectionRange' support of language server
  call lh#menu#make('nx', s:coc_prio.'170', s:coc_menu.'Range Select',                 '<leader>rs', '<Plug>(coc-range-select)')


  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  " Remap <C-f> and <C-b> to scroll float windows/popups
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  endif

  amenu 50.120.199 &Plugin.&COC.---<sep>--- <Nop>
  " Use `:Format` to format current buffer
  command! -nargs=0 Format :call CocActionAsync('format')

  " Use `:Fold` to fold current buffer
  command! -nargs=? Fold   :call CocAction('fold', <f-args>)

  " Organize imports
  command! -nargs=0 OrganizeImports :call CocActionAsync('runCommand', 'editor.action.organizeImport')

  " Toggle/Hide CocOutline
  function! s:MyCocOutline(bang, ...) abort
    let act = get(a:, 1, '')
    if act =~? '\vs%[show]'
      call CocAction('showOutline')
    elseif act =~? '\vc%[lose]|h%[ide]'
      call CocAction('hideOutline')
    elseif act =~? '\vt%[oggle]|!' || a:bang =='!'
      let winid = coc#window#find('cocViewId', 'OUTLINE')
      if  winid >= 0
        call coc#window#close(winid)
      else
        call CocAction('showOutline')
      endif
    else
      call lh#common#warning_msg("Unknow action: Select show/hide/toggle")
    endif
  endfunction
  function! s:CocOutlineComplete(...) abort
    return ['show', 'hide', 'toggle']
  endfunction
  command! -bang -nargs=? -complete=customlist,s:CocOutlineComplete
        \ Outline call s:MyCocOutline("<bang>", <f-args>)

  " Add diagnostic info for https://github.com/itchyny/lightline.vim
  let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
        \ },
        \ 'component_function': {
        \   'cocstatus': 'coc#status'
        \ },
        \ }

  let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

  " Using CocList
  " Show all diagnostics
  call lh#menu#make('n', s:coc_prio.'200', s:coc_menu.'Show all &Diagnostic',                '<leader>ca',  ':<C-u>CocList diagnostics<cr>')
  " Manage extensions
  call lh#menu#make('n', s:coc_prio.'210', s:coc_menu.'&Manage extensions',                  '<leader>ce',  ':<C-u>CocList extensions<cr>')
  " Show commands
  call lh#menu#make('n', s:coc_prio.'220', s:coc_menu.'Show Commands',                       '<leader>cc',  ':<C-u>CocList commands<cr>')
  " Find symbol of current document
  call lh#menu#make('n', s:coc_prio.'230', s:coc_menu.'Show &Outline',                       '<leader>cO',  ':<C-u>CocList outline<cr>')
  " Search workspace symbols
  call lh#menu#make('n', s:coc_prio.'240', s:coc_menu.'Search Workspace &Symbols',           '<leader>cs',  ':<C-u>CocList -I symbols<cr>')
  " Do default action for next item.
  call lh#menu#make('n', s:coc_prio.'250', s:coc_menu.'Do default action for next item',     '<leader>cdn',  ':<C-u>CocNext<cr>')
  " Do default action for previous item.
  call lh#menu#make('n', s:coc_prio.'260', s:coc_menu.'Do default action for previous item', '<leader>cdp',  ':<C-u>CocPrev<CR>')
  " Resume latest coc list
  call lh#menu#make('n', s:coc_prio.'270', s:coc_menu.'Resume latest coc list',              '<leader>cr',  ':<C-u>CocListResume<CR>')

  if executable('ccls') && executable('clang++')
    " # Playing with the API...
    " :let cclsid = filter(lh#list#get(CocAction('services'), 'id'), 'v:val =~ "ccls"')[0]
    " :let symbols = CocRequest(cclsid, 'workspace/symbol', {'query': 'apattern'})
    " -> returns a list of definitions and declarations mathing the pattern
    " see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
    " and for symbol kinds: https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
    "
    " :echo CocRequest(cclsid, 'textDocument/documentSymbol', {'textDocument': {'uri': 'file://'.expand('%:p')} })
    " -> lists all symbols defined in the current document
    " --> Alas it doesn't permit to extract scopes/contexts (classes, namespaces, functions...)
    " see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
    "
    " :echo CocRequest(cclsid, 'textDocument/definition', {'textDocument': {'uri': 'file://'.expand('%:p')}, 'posision':{'line':line('.')-1,'character': col('.')-1}})
    " -> should return where the symbol under the cursor is defined.
    "    But I cannot make it work!!!
    " see https://microsoft.github.io/language-server-protocol/specification#textDocument_definition
    "
    " However if :Check is a command that stores its `<f-args>` the following
    " permits to extract where the symbol is defined
    " :call CocAction('jumpDefinition', 'Check')
    "
    " # $ccls/navigate
    "   Semantic navigation. Roughly,
    "   D" => first child declaration "L" => previous declaration "R" => next declaration "U" => parent declaration
    "   TODO: move to ftplugin
    " nn <silent><buffer> <C-l> :call CocLocations('ccls','$ccls/navigate',{'direction':'D'})<cr>
    " nn <silent><buffer> <C-k> :call CocLocations('ccls','$ccls/navigate',{'direction':'L'})<cr>
    " nn <silent><buffer> <C-j> :call CocLocations('ccls','$ccls/navigate',{'direction':'R'})<cr>
    " nn <silent><buffer> <C-h> :call CocLocations('ccls','$ccls/navigate',{'direction':'U'})<cr>
    "
    " # Cross reference extensions
    function! s:coc_bind_colocate(key, prio, text, what, ...) abort
      " Evaluate all functions now
      " let a000 = map(deepcopy(a:000), {k0,v0 -> string(map(v0, { k, v -> type(v)==2 ? v() : v}))})
      " let arg = join([string('$ccls/'.a:what)] + a000, ', ')
      let arg = string('$ccls/'.a:what)
      for a in a:000
        call lh#assert#type(a).is({})
        let arg .= ', {'
        let args = []
        for [k,l:V] in items(a)
          " Little trick to inject v:count that shall not be evaluated
          " yet -> It's passed through a lambda
          let args += [string(k).': '.(type(l:V)==type(function('has')) ? l:V() : string(l:V))]
        endfor
        let arg .= join(args, ', ') . '}'
      endfor
      call lh#menu#make('n', s:coc_prio.a:prio, s:coc_menu.a:text, a:key, ':<c-u>call CocLocations("ccls", '.arg.')<cr>')
    endfunction

    " ccls/vars ccls/base ccls/derived ccls/members have a parameter while others are interactive.
    " (ccls/base 1) direct bases
    " (ccls/derived 1) direct derived
    " (ccls/member 2) => 2 (Type) => nested classes / types in a namespace
    " (ccls/member 3) => 3 (Func) => member functions / functions in a namespace
    " (ccls/member 0) => member variables / variables in a namespace
    " (ccls/vars 1) => field
    " (ccls/vars 2) => local variable
    " (ccls/vars 3) => field or local variable. 3 = 1 | 2
    " (ccls/vars 4) => parameter
    "
    " Bases & Children
    amenu 50.120.299 &Plugin.&COC.----<sep>---- <Nop>
    call s:coc_bind_colocate('<leader>gb', '300', 'Direct base class (count=1 level)', 'inheritance', {'levels': {-> 'v:count1'}})
    call s:coc_bind_colocate('<leader>gB', '310', 'Base classes up to 3 levels',       'inheritance', {'levels': 3})
    call s:coc_bind_colocate('<leader>gd', '320', 'Derived class (count=1 level)',     'inheritance', {'derived': v:true, 'levels': {-> 'v:count1'}})
    call s:coc_bind_colocate('<leader>gD', '330', 'Derived classes ut to 3 levels',    'inheritance', {'derived': v:true, 'levels': 3})

    " caller/callee
    call s:coc_bind_colocate('<leader>gc', '340', 'Caller', 'call')
    call s:coc_bind_colocate('<leader>gC', '350', 'Callee', 'call', {'callee': v:true})

    " $ccls/member
    " member variables / variables in a namespace
    call s:coc_bind_colocate('<leader>gm', '350', 'Variables (member/namespace)',  'member')
    call s:coc_bind_colocate('<leader>gf', '360', 'Functions (member/namespace)',  'member', {'kind': 3})
    call s:coc_bind_colocate('<leader>gs', '370', 'Nested classes (/types in ns)', 'member', {'kind': 2})

    call s:coc_bind_colocate('<leader>gv', '380', 'Variables',  'vars')
    call s:coc_bind_colocate('<leader>gV', '390', 'Variables (fields)',  'vars', {'kind': 1})
    call s:coc_bind_colocate('<leader>gP', '400', 'Parameters',  'vars', {'kind': 4})

    " Inject in coc/ccls settings:
    " - clangs system paths (dynamic)
    " - SplitIfNotOpen4COC (done earlier)
  endif
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
