"=============================================================================
" File:         autoload/dirdiff.vim                              {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-misc>
" Version:      2.0.0
let s:k_version = 200
" Created:      03rd Jul 2017
" Last Update:  26th Nov 2024
"------------------------------------------------------------------------
" Description:
"       Support functions for William Lee's dirdiff plugin
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! dirdiff#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! dirdiff#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! dirdiff#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Set some script specific variables:
let s:DirDiffFirstDiffLine = 6
let s:DirDiffALine = 1
let s:DirDiffBLine = 2

" -- Variables used in various utilities
if has("unix")
    let s:DirDiffCopyCmd               = "cp"
    let s:DirDiffCopyFlags             = ""
    let s:DirDiffCopyDirCmd            = "cp"
    let s:DirDiffCopyDirFlags          = "-rf"
    let s:DirDiffCopyInteractiveFlag   = "-i"

    let s:DirDiffDeleteCmd             = "rm"
    let s:DirDiffDeleteFlags           = ""
    let s:DirDiffDeleteInteractiveFlag = "-i"

    let s:DirDiffDeleteDirCmd          = "rm"
    let s:DirDiffDeleteDirFlags        = "-rf"

    let s:sep                          = "/"

    let s:DirDiffMakeDirCmd            = "!mkdir "

elseif has("win32")
    let s:DirDiffCopyCmd               = "copy"
    let s:DirDiffCopyFlags             = ""
    let s:DirDiffCopyDirCmd            = "xcopy"
    let s:DirDiffCopyDirFlags          = "/e /i /q"
    let s:DirDiffCopyInteractiveFlag   = "/-y"

    let s:DirDiffDeleteCmd             = "del"
    let s:DirDiffDeleteFlags           = "/s /q"
    let s:DirDiffDeleteInteractiveFlag = "/p"
    " Windows is somewhat stupid since "del" can only remove the files, not
    " the directory.  The command "rd" would remove files recursively, but it
    " doesn't really work on a file (!).  where is the deltree command???

    let s:DirDiffDeleteDirCmd          = "rd"
    " rd is by default prompting, we need to handle this in a different way
    let s:DirDiffDeleteDirFlags        = "/s"
    let s:DirDiffDeleteDirQuietFlag    = "/q"

    let s:sep                          = "\\"

    let s:DirDiffMakeDirCmd            = "!mkdir "
else
    " Platforms not supported
    let s:DirDiffCopyCmd               = ""
    let s:DirDiffCopyFlags             = ""
    let s:DirDiffDeleteCmd             = ""
    let s:DirDiffDeleteFlags           = ""
    let s:sep                          = ""
endif

" let s:DirDiffDiffCmd = '/home/atvlh/bin/diff'
let s:DirDiffDiffCmd = get(g:, 'DirDiffDiffCmd', 'diff')
if !executable(s:DirDiffDiffCmd)
    let s:DirDiffDiffCmd = matchstr(globpath(substitute($PATH,':',',','g'), 'diff'), '.\{-}\ze\n')
endif
if !get(g:, 'HasGNUDIFF', 1)
    " problem with diff on some old solaris versions
    " @todo test whether diff supports --brief
    let s:DirDiffDiffCmdArg   = ' -r'
    let s:DiffSupportsBrief   = 0
    let s:DiffSupportsExclude = 0
    let s:DiffSupportsIgnore  = 0
else
    let s:DirDiffDiffCmdArg   = ' -r --brief'
    let s:DiffSupportsBrief   = 1
    let s:DiffSupportsExclude = 1
    let s:DiffSupportsIgnore  = 1
endif

function! dirdiff#DirDiff(srcA, srcB) abort
    " Setup
    let DirDiffAbsSrcA = fnamemodify(expand(a:srcA, ":p"), ":p")
    let DirDiffAbsSrcB = fnamemodify(expand(a:srcB, ":p"), ":p")

    " Check for an internationalized version of diff ?
    call <SID>GetDiffStrings()

    " Remove the trailing \ or /
    let DirDiffAbsSrcA = substitute(DirDiffAbsSrcA, '\\$\|/$', '', '')
    let DirDiffAbsSrcB = substitute(DirDiffAbsSrcB, '\\$\|/$', '', '')

    let DiffBuffer = tempname()
    " We first write to that file
    " Constructs the command line
    let langStr = ""
    let cmd = g:DirDiffLangString . s:DirDiffDiffCmd
    let cmdarg = s:DirDiffDiffCmdArg

    " If variable is set, we ignore the case
    if (g:DirDiffIgnoreCase)
        let cmdarg .= " -i"
    endif
    if (g:DirDiffAddArgs != "")
        let cmdarg .= " ".g:DirDiffAddArgs." "
    endif
    if (g:DirDiffExcludes != "") && s:DiffSupportsExclude
        let cmdarg .= " -x'".substitute(g:DirDiffExcludes, ',', "' -x'", 'g')."'"
    endif
    if (g:DirDiffIgnore != "") && s:DiffSupportsIgnore
        let cmdarg .= " -I'".substitute(g:DirDiffIgnore, ',', "' -I'", 'g')."'"
    endif
    " Prompt the user for additional arguments
"    let addarg = input("Additional diff args (current =". cmdarg. "): ")
    let addarg = ""
    " let cmd .=cmdarg." ".addarg." '".DirDiffAbsSrcA."' '".DirDiffAbsSrcB."'"
    " let cmd .=" > '".DiffBuffer."'"
    " let cmd = '!' . cmd
    let cmd .= cmdarg." ".addarg
                \ ." ". lh#path#fix(DirDiffAbsSrcA)
                \ ." ". lh#path#fix(DirDiffAbsSrcB)

    let stuffToIgnore = !s:DiffSupportsIgnore && 0!=strlen(g:DirDiffIgnore)
    if ! s:DiffSupportsBrief || stuffToIgnore
        let ignorePattern = stuffToIgnore ?
                    \ '|'.substitute(escape(g:DirDiffIgnore,'[]*.$'), ',', '|', 'g')
                    \ : ''
        let cmd .= " | egrep '^".g:DirDiffTextOnlyIn.'|^diff '.ignorePattern."'"
    endif

    echo "Diffing directories, it may take a while..."
    " let error = dirdiff#DirDiffExec(cmd, 0)
    if &verbose
        echomsg 'Executing: '.cmd
    endif
    try
        let lang_ctx = lh#lang#set_message_temporarily('C')
        let res = system(cmd)
    finally
        call lang_ctx.finalize()
    endtry
    if (v:shell_error == 0)
        echo "There is no diff here."
        " return
    endif
    " exe "edit ".DiffBuffer.&shellxquote
    silent exe "edit ".DiffBuffer
    let s:buffer_dir = bufnr('%')
    silent! 0put=res
    if &verbose
        let g:res = res
    endif
    silent! 1delete _
    " echo "Defining [A] and [B] ... "
    " We then do a substitution on the directory path
    " We need to do substitution of the the LONGER string first, otherwise
    " it'll mix up the A and B directory
    if (strlen(DirDiffAbsSrcA) > strlen(DirDiffAbsSrcB))
        silent! exe "%s/".<SID>EscapeDirForRegex(DirDiffAbsSrcA)."/[A]/"
        silent! exe "%s/".<SID>EscapeDirForRegex(DirDiffAbsSrcB)."/[B]/"
    else
        silent! exe "%s/".<SID>EscapeDirForRegex(DirDiffAbsSrcB)."/[B]/"
        silent! exe "%s/".<SID>EscapeDirForRegex(DirDiffAbsSrcA)."/[A]/"
    endif

    if ! s:DiffSupportsBrief
        exe 'silent! %s#\s*\zsdiff\%( \+-\S\+\)* \(.\{-}\) \(\[B\].*\)#'.g:DirDiffTextFiles.'\1'.g:DirDiffTextAnd.'\2'.g:DirDiffTextDiffer.'#'
    endif
    if stuffToIgnore
        " For echo purpose
        let cmdarg .= ' -I '.substitute(g:DirDiffIgnore, ',', '|', 'g')
    endif
    if (! s:DiffSupportsExclude) && 0!=strlen(g:DirDiffExcludes)
        echomsg 'Excluding: g/'.  substitute(s:EscapeDirForRegex(g:DirDiffExcludes), ',', '\\|', 'g') .'/d_'
        exe 'silent! g/'.  substitute(s:EscapeDirForRegex(g:DirDiffExcludes), ',', '\\|', 'g') .'/d_'
        " For echo purpose
        let cmdarg .= ' -x '.substitute(g:DirDiffExcludes, ',', '|', 'g')
    endif
    " In windows, diff behaves somewhat weirdly, for the appened path it'll
    " use "/" instead of "\".  Convert this to \
    if (has("win32"))
        silent! %s#/#\\#g
    endif

    echo "Sorting entries ..."
    " We then sort the lines if the option is set
    if (g:DirDiffSort == 1)
        if exists('*sort') | %sort
        else               | %Sort
            " requires system_utils.vim
        endif
    endif

    " Put in spacer in front of each line
    silent! %s/^/    /

    " We then put the file [A] and [B] on top of the diff lines
    call append(0, "[A]=". DirDiffAbsSrcA)
    call append(1, "[B]=". DirDiffAbsSrcB)
    if g:DirDiffEnableMappings
        call append(2, "Usage:   <Enter>/'o'=open,'s'=sync,'<Leader>dg'=diffget,'<Leader>dp'=diffput,'<Leader>dj'=next,'<Leader>dk'=prev, 'q'=quit")
    else
        call append(2, "Usage:   <Enter>/'o'=open,'s'=sync,'q'=quit")
    endif
    call append(3, "Options: 'u'=update,'x'=set excludes,'i'=set ignore,'a'=set args,'c'=copy args" )
    call append(4, "Diff Args:" . cmdarg . " Copy args:" . s:DirDiffCopyFlags)
    call append(5, "")
    " go to the beginning of the file
    0
    setlocal filetype=dirdiff
    setlocal nomodified
    setlocal nomodifiable
    setlocal buftype=nowrite
    "setlocal buftype=nofile
    "setlocal bufhidden=delete
    setlocal bufhidden=hide
    setlocal nowrap

    " Set up local key bindings
    " 'n' actually messes with the search next pattern, I think using \dj and
    " \dk is enough.  Otherwise, use j,k, and enter.
"    nnoremap <buffer> n :call dirdiff#DirDiffNext()<CR>
"    nnoremap <buffer> p :call dirdiff#DirDiffPrev()<CR>
    nnoremap <buffer> s :. call dirdiff#DirDiffSync()<CR>
    vnoremap <buffer> s :call dirdiff#DirDiffSync()<CR>
    nnoremap <buffer> u :call dirdiff#DirDiffUpdate()<CR>
    nnoremap <buffer> x :call <SID>ChangeExcludes()<CR>
    nnoremap <buffer> a :call <SID>ChangeArguments()<CR>
    nnoremap <buffer> i :call <SID>ChangeIgnore()<CR>
    nnoremap <buffer> c :call <SID>ChangeCopy()<CR>
    nnoremap <buffer> q :call dirdiff#DirDiffQuit()<CR>

    nnoremap <buffer> o    :call dirdiff#DirDiffOpen()<CR>
    nnoremap <buffer> <CR> :call dirdiff#DirDiffOpen()<CR>
    nnoremap <buffer> <2-Leftmouse> :call dirdiff#DirDiffOpen()<CR>
    nnoremap <buffer> A    :call <SID>GotoBuffer('A')<CR>
    nnoremap <buffer> B    :call <SID>GotoBuffer('B')<CR>
    call <SID>SetupSyntax()

    " Open the first diff
    call dirdiff#DirDiffNext()
endfunction

function! s:GotoBuffer(buffer) abort
    let res = lh#buffer#find(s:buffer_{a:buffer})
    if -1 == res
        echoerr "DirDiff: No [".a:buffer."] to jump to"
    endif
endfunction

" Set up syntax highlighing for the diff window
function! <SID>SetupSyntax() abort
    if has("syntax") && exists("g:syntax_on")
        "&& !has("syntax_items")
        syn match DirDiffSrcA               "\[A\]"
        syn match DirDiffSrcB               "\[B\]"
        syn match DirDiffUsage              "^Usage.*"
        syn match DirDiffOptions            "^Options.*"
        exec 'syn match DirDiffFiles              "' . s:DirDiffDifferLine .'"'
        exec 'syn match DirDiffOnly               "' . s:DirDiffDiffOnlyLine . '"'
        syn match DirDiffSelected           "^==>.*" contains=DirDiffSrcA,DirDiffSrcB

        hi def link DirDiffSrcA               Directory
        hi def link DirDiffSrcB               Type
        hi def link DirDiffUsage              Special
        hi def link DirDiffOptions            Special
        hi def link DirDiffFiles              String
        hi def link DirDiffOnly               PreProc
        hi def link DirDiffSelected           DiffChange
    endif
endfunction

" You should call this within the diff window
function! dirdiff#DirDiffUpdate() abort
    let dirA = <SID>GetBaseDir("A")
    let dirB = <SID>GetBaseDir("B")
    call dirdiff#DirDiff(dirA, dirB)
endfun

" Quit the DirDiff mode
function! dirdiff#DirDiffQuit() abort
    let in = confirm ("Are you sure you want to quit DirDiff?", "&Yes\n&No", 2)
    if (in == 1)
        call <SID>CloseDiffWindows()
        bd!
    endif
endfun

" Returns an escaped version of the path for regex uses
" LH: patched
function! <SID>EscapeDirForRegex(path) abort
    " This list is probably not complete, modify later
    let path = escape(a:path, "[]$^~")
    let path = substitute(path, '[/\\]', '[/\\\\]', 'g')
    return path
endfunction

" Close the opened diff comparison windows if they exist
function! s:CloseWindow(buff) abort
    let w = bufwinnr(a:buff)
    if w > 0
        exe w.'wincmd w'
        call s:AskIfModified()
        bd!
    endif
endfunction

function! <SID>CloseDiffWindows() abort
    if exists('s:buffer_O') | call s:CloseWindow(s:buffer_O) | endif
    if exists('s:buffer_A') | call s:CloseWindow(s:buffer_A) | endif
    if exists('s:buffer_B') | call s:CloseWindow(s:buffer_B) | endif
    return
    if (<SID>AreDiffWinsOpened())
        wincmd k
        " Ask the user to save if buffer is modified
        call <SID>AskIfModified()
        bd!
        " User may just have one window opened, we may not need to close
        " the second diff window
        if (&diff)
            call <SID>AskIfModified()
            bd!
        endif
    endif
endfunction


function! dirdiff#DirDiffOpen() abort
    " First dehighlight the last marked
    call <SID>DeHighlightLine()

    " Mark the current location of the line
    "mark n
    let b:currentDiff = line(".")

    " We first parse back the [A] and [B] directories from the top of the line
    let dirA = <SID>GetBaseDir("A")
    let dirB = <SID>GetBaseDir("B")

    call <SID>CloseDiffWindows()

    let line = getline(".")
    " Parse the line and see whether it's a "Only in" or "Files Differ"
    call <SID>HighlightLine()
    let fileA = <SID>GetFileNameFromLine("A", line)
    let fileB = <SID>GetFileNameFromLine("B", line)
    if <SID>IsOnly(line)
        " We open the file
        let fileSrc = <SID>ParseOnlySrc(line)
        if (fileSrc == "A")
            let fileToOpen = fileA
        elseif (fileSrc == "B")
            let fileToOpen = fileB
        endif
        silent exec "split ".fileToOpen
        let s:buffer_O = bufnr('%')
        " Fool the window saying that this is diff
        " diffthis
        wincmd j
        " Resize the window
        exe("resize " . g:DirDiffWindowSize)
        exe (b:currentDiff)
    elseif <SID>IsDiffer(line)
        "Open the diff windows
        " split
        " wincmd k
        let diff_win = bufwinnr('%')
        silent exec "split ".fnameescape(fileB)
        let s:buffer_B = bufnr('%')
        silent exec "vert diffsplit ".fnameescape(fileA)
        let s:buffer_A = bufnr('%')
        " Go back to the diff window
        exe diff_win.'wincmd w'
        wincmd j
        " Resize the window
        exe("resize " . g:DirDiffWindowSize)
        exe (b:currentDiff)
        " Center the line
        exe ("normal z.")
    else
        echo "There is no diff at the current line!"
    endif
endfunction

" Ask the user to save if the buffer is modified
"
function! <SID>AskIfModified() abort
    if (&modified)
        let input = confirm("File " . expand("%:p") . " has been modified.", "&Save\nCa&ncel", 1)
        if (input == 1)
            w!
        endif
    endif
endfunction

function! <SID>HighlightLine() abort
    let savedLine = line(".")
    exe get(b:, 'currentDiff', 0)
    setlocal modifiable
    let line = getline(".")
    let line = substitute(line, '^    ', '==> ', '')
    call setline('.', line)
    setlocal nomodifiable
    setlocal nomodified
    exe (savedLine)
    redraw
endfunction

function! <SID>DeHighlightLine() abort
    let savedLine = line(".")
    exe (b:currentDiff)
    let line = getline(".")
    setlocal modifiable
    let line = substitute(line, '^==> ', '    ', '')
    call setline('.', line)
    setlocal nomodifiable
    setlocal nomodified
    exe (savedLine)
    redraw
endfunction

" Returns the directory for buffer "A" or "B".  You need to be in the diff
" buffer though.
function! <SID>GetBaseDir(diffName) abort
    let currLine = line(".")
    if (a:diffName == "A")
        let baseLine = s:DirDiffALine
    else
        let baseLine = s:DirDiffBLine
    endif
    let regex = '\['.a:diffName.'\]=\(.*\)'
    let line = getline(baseLine)
    let rtn = substitute(line, regex , '\1', '')
    return rtn
endfunction

function! dirdiff#DirDiffNext() abort
    " If the current window is a diff, go down one
    if (&diff == 1)
        wincmd j
    endif
    " if the current line is <= 6, (within the header range), we go to the
    " first diff line open it
    if (line(".") < s:DirDiffFirstDiffLine)
        exe (s:DirDiffFirstDiffLine)
        let b:currentDiff = line(".")
    endif
    silent! exe (b:currentDiff + 1)
    call dirdiff#DirDiffOpen()
endfunction

function! dirdiff#DirDiffPrev() abort
    " If the current window is a diff, go down one
    if (&diff == 1)
        wincmd j
    endif
    silent! exe (b:currentDiff - 1)
    call dirdiff#DirDiffOpen()
endfunction

" For each line, we can perform a recursive copy or delete to sync up the
" difference. Returns non-zero if the operation is NOT successful, returns 0
" if everything is fine.
"
function! dirdiff#DirDiffSyncHelper(AB, line) abort
    let fileA = <SID>GetFileNameFromLine("A", a:line)
    let fileB = <SID>GetFileNameFromLine("B", a:line)
"    echo "Helper line is ". a:line. " fileA " . fileA . " fileB " . fileB
    if <SID>IsOnly(a:line)
        " If a:AB is "A" and the ParseOnlySrc returns "A", that means we need to
        " copy
        let fileSrc = <SID>ParseOnlySrc(a:line)
        let operation = ""
        if (a:AB == "A" && fileSrc == "A")
            let operation = "Copy"
            " Use A, and A has source, thus copy the file from A to B
            let fileFrom = fileA
            let fileTo = fileB
        elseif (a:AB == "A" && fileSrc == "B")
            let operation = "Delete"
            " Use A, but B has source, thus delete the file from B
            let fileFrom = fileB
            let fileTo = fileA
        elseif (a:AB == "B" && fileSrc == "A")
            let operation = "Delete"
            " Use B, but the source file is A, thus removing A
            let fileFrom = fileA
            let fileTo = fileB
        elseif (a:AB == "B" && fileSrc == "B")
            " Use B, and B has the source file, thus copy B to A
            let operation = "Copy"
            let fileFrom = fileB
            let fileTo = fileA
        endif
    elseif <SID>IsDiffer(a:line)
        " Copy no matter what
        let operation = "Copy"
        if (a:AB == "A")
            let fileFrom = fileA
            let fileTo = fileB
        elseif (a:AB == "B")
            let fileFrom = fileB
            let fileTo = fileA
        endif
    else
        echo "There is no diff here!"
        " Error
        return 1
    endif
    if (operation == "Copy")
        let rtnCode = <SID>Copy(fileFrom, fileTo)
    elseif (operation == "Delete")
        let rtnCode = <SID>Delete(fileFrom)
    endif
    return rtnCode
endfunction

" Synchronize the range
function! dirdiff#DirDiffSync() range abort
    let answer = 1
    let silence = 0
    let syncMaster = "A"
    let currLine = a:firstline
    let lastLine = a:lastline
    let syncCount = 0

    while ((currLine <= lastLine))
        " Update the highlight
        call <SID>DeHighlightLine()
        let b:currentDiff = currLine
        call <SID>HighlightLine()
        let line = getline(currLine)
        if (!silence)
            let answer = confirm(substitute(line, "^....", '', ''). "\nSynchronization option:" , "&A -> B\n&B -> A\nA&lways A\nAl&ways B\n&Skip\nCa&ncel", 6)
            if (answer == 1 || answer == 3)
                let syncMaster = "A"
            endif
            if (answer == 2 || answer == 4)
                let syncMaster = "B"
            endif
            if (answer == 3 || answer == 4)
                let silence = 1
            endif
            if (answer == 5)
                let currLine += 1
                continue
            endif
            if (answer == 6)
                break
            endif
        endif

"        call <SID>DeHighlightLine()
        let rtnCode = dirdiff#DirDiffSyncHelper(syncMaster, line)
        if (rtnCode == 0)
            " Successful
            let syncCount += 1
            " Assume that the line is synchronized, we delete the entry
            setlocal modifiable
            silent exe (currLine.",".currLine." delete_")
            setlocal nomodifiable
            setlocal nomodified
            let lastLine -= 1
        else
            " Failed!
            let currLine += 1
        endif
    endwhile
    echo syncCount . " diff item(s) synchronized."
endfunction

" Return file "A" or "B" depending on the line given.  If it's a Only line,
" either A or B does not exist, but the according value would be returned.
function! <SID>GetFileNameFromLine(AB, line) abort
    " Determine where the source of the copy is.
    let dirA = <SID>GetBaseDir("A")
    let dirB = <SID>GetBaseDir("B")

    let fileToProcess = ""

    if <SID>IsOnly(a:line)
        let fileToProcess = <SID>ParseOnlyFile(a:line)
    elseif <SID>IsDiffer(a:line)
        let regex = '^.*' . s:DirDiffDifferLine . '\[A\]\(.*\)' . s:DirDiffDifferAndLine . '\[B\]\(.*\)' . s:DirDiffDifferEndLine . '.*$'
        let fileToProcess = substitute(a:line, regex, '\1', '')
    else
    endif

    if &verbose
        echomsg "line : " . a:line. "AB:" . a:AB . " File to Process:" . fileToProcess
    endif
    if (a:AB == "A")
        return dirA . fileToProcess
    elseif (a:AB == "B")
        return dirB . fileToProcess
    else
        return ""
    endif
endfunction

"Returns the source (A or B) of the "Only" line
function! <SID>ParseOnlySrc(line) abort
    return substitute(a:line, '^.*' . s:DirDiffDiffOnlyLine . '\[\(.\)\].*:.*', '\1', '')
endfunction

function! <SID>ParseOnlyFile(line) abort
    let regex = '^.*' . s:DirDiffDiffOnlyLine . '\[.\]\(.*\): \(.*\)'
    let root = substitute(a:line, regex , '\1', '')
    let file = root . s:sep . substitute(a:line, regex , '\2', '')
    return file
endfunction

function! <SID>Copy(fileFromOrig, fileToOrig) abort
    let fileFrom = substitute(a:fileFromOrig, '/', s:sep, 'g')
    let fileTo = substitute(a:fileToOrig, '/', s:sep, 'g')
    echo "Copy from " . fileFrom . " to " . fileTo
    if (s:DirDiffCopyCmd == "")
        echo "Copy not supported on this platform"
        return 1
    endif

    let error = 0
    if (isdirectory(fileFrom))
        " Constructs the copy directory command
        let copydircmd = "!".s:DirDiffCopyDirCmd." ".s:DirDiffCopyDirFlags
        " Append the interactive flag
        if (g:DirDiffInteractive)
            let copydircmd .= " " . s:DirDiffCopyInteractiveFlag
        endif
        let copydircmd .= ' '
                    \ . lh#path#fix(fileFrom) . ' '
                    \ . lh#path#fix(fileTo)
        let copydircmd = '!'.lh#system#SysCopyDir(fileFrom, fileTo)
        " echomsg copydircmd
        let error = dirdiff#DirDiffExec(copydircmd, g:DirDiffInteractive)
    else
        " Constructs the copy command
        let copycmd = "!".s:DirDiffCopyCmd." ".s:DirDiffCopyFlags
        " Append the interactive flag
        if (g:DirDiffInteractive)
            let copycmd .= " " . s:DirDiffCopyInteractiveFlag
        endif
        let copycmd .= " \"".fileFrom."\" \"".fileTo."\""
        let copycmd = '!'.lh#system#SysCopy(fileFrom, fileTo)
        let error = dirdiff#DirDiffExec(copycmd, g:DirDiffInteractive)
    endif
    if (error != 0)
        echo "Can't copy from " . fileFrom . " to " . fileTo
        return 1
    endif
    return 0
endfunction

" Would execute the command, either silent or not silent, by the
" interactive flag ([0|1]).  Returns the v:shell_error after
" executing the command.
function! dirdiff#DirDiffExec(cmd, interactive) abort
    let error = 0
    if (a:interactive)
        exe (a:cmd)
    else
        silent exe (a:cmd)
    endif
    let error = v:shell_error
    call s:Verbose('DirDiffExec(%1, %2) -> %3', a:cmd, a:interactive, error)
    return error
endfunction

" Delete the file or directory.  Returns 0 if nothing goes wrong, error code
" otherwise.
function! <SID>Delete(fileFromOrig) abort
    let fileFrom = substitute(a:fileFromOrig, '/', s:sep, 'g')
    echo "Deleting from " . fileFrom
    if (s:DirDiffDeleteCmd == "")
        echo "Delete not supported on this platform"
        return 1
    endif

    let delcmd = ""

    if (isdirectory(fileFrom))
        let delcmd = "!".s:DirDiffDeleteDirCmd." ".s:DirDiffDeleteDirFlags
        if (g:DirDiffInteractive)
            " If running on Unix, and we're running in interactive mode, we
            " append the -i tag
            if (has("unix"))
                let delcmd .= " " . s:DirDiffDeleteInteractiveFlag
            endif
        else
            " If running on windows, and we're not running in interactive
            " mode, we append the quite flag to the "rd" command
            if (has("win32"))
                let delcmd .= " " . s:DirDiffDeleteDirQuietFlag
            endif
        endif
    else
        if exists('*delete')
            let error = delete(a:fileFromOrig)
            if (error != 0)
                echo "Can't delete " . fileFrom
            endif
            return error
        else
            let delcmd = "!".s:DirDiffDeleteCmd." ".s:DirDiffDeleteFlags
            if (g:DirDiffInteractive)
                let delcmd .= " " . s:DirDiffDeleteInteractiveFlag
            endif
        endif
    endif

    let delcmd .=" \"".fileFrom."\""
    let error = dirdiff#DirDiffExec(delcmd, g:DirDiffInteractive)
    if (error != 0)
        echo "Can't delete " . fileFrom
    endif
    return error
endfunction

function! <SID>AreDiffWinsOpened() abort
    let currBuff = expand("%:p")
    let currLine = line(".")
    wincmd k
    let abovedBuff = expand("%:p")
    let abovedIsDiff = &diff
    " Go Back if the aboved buffer is not the same
    if (currBuff != abovedBuff)
        wincmd j
        " Go back to the same line
        exe (currLine)
        return abovedIsDiff
        " Aboved is just a bogus buffer, not a diff buffer
    else
        exe (currLine)
        return 0
    endif
endfunction

" The given line begins with the "Only in"
function! <SID>IsOnly(line) abort
    return (match(a:line, "^ *" . s:DirDiffDiffOnlyLine . "\\|^==> " . s:DirDiffDiffOnlyLine ) == 0)
endfunction

" The given line begins with the "Files"
function! <SID>IsDiffer(line) abort
    return (match(a:line, "^ *" . s:DirDiffDifferLine . "\\|^==> " . s:DirDiffDifferLine  ) == 0)
endfunction

" Let you modify the Exclude patthern
function! <SID>ChangeExcludes() abort
    let g:DirDiffExcludes = input ("Exclude pattern (separate multiple patterns with ','): ", g:DirDiffExcludes)
    echo "\nPress update ('u') to refresh the diff."
endfunction

" Let you modify additional arguments for diff
function! <SID>ChangeArguments() abort
    let g:DirDiffAddArgs = input ("Additional diff args: ", g:DirDiffAddArgs)
    echo "\nPress update ('u') to refresh the diff."
endfunction

" Let you modify the Ignore patthern
function! <SID>ChangeIgnore() abort
    let g:DirDiffIgnore = input ("Ignore pattern (separate multiple patterns with ','): ", g:DirDiffIgnore)
    echo "\nPress update ('u') to refresh the diff."
endfunction

" Let you modify the Ignore patthern
function! <SID>ChangeCopy() abort
    let s:DirDiffCopyFlags = input ("Copy arguments: ", s:DirDiffCopyFlags)
endfunction

" Added to deal with internationalized version of diff, which returns a
" different string than "Files ... differ" or "Only in ... "
function! <SID>GetDiffStrings() abort
    " Check if we have the dynamic text string turned on.  If not, just return
    " what's set in the global variables

    if (g:DirDiffDynamicDiffText == 0 || !s:DiffSupportsBrief)
        let s:DirDiffDiffOnlyLine = g:DirDiffTextOnlyIn
        let s:DirDiffDifferLine = g:DirDiffTextFiles
        let s:DirDiffDifferAndLine = g:DirDiffTextAnd
        let s:DirDiffDifferEndLine = g:DirDiffTextDiffer
        return
    endif

    let tmp1 = tempname()
    let tmp2 = tempname()
    let tmpdiff = tempname()

    " We need to pad the backslashes in order to make it match
    let tmp1rx = <SID>EscapeDirForRegex(tmp1)
    let tmp2rx = <SID>EscapeDirForRegex(tmp2)
    let tmpdiffrx = <SID>EscapeDirForRegex(tmpdiff)

    silent exe s:DirDiffMakeDirCmd . "\"" . tmp1 . "\""
    silent exe s:DirDiffMakeDirCmd . "\"" . tmp2 . "\""
    silent exe "!echo test > \"" . tmp1 . s:sep . "test" . "\""
    silent exe "!" . g:DirDiffLangString . "diff -r --brief \"" . tmp1 . "\" \"" . tmp2 . "\" > \"" . tmpdiff . "\""

    " Now get the result of that diff cmd
    silent exe "split ". fnameescape(tmpdiff)
    "echo "First line: " . getline(1)
    "echo "tmp1: " . tmp1
    "echo "tmp1rx: " . tmp1rx
    let s:DirDiffDiffOnlyLine = substitute( getline(1), tmp1rx . ".*$", "", '')
    "echo "DirDiff Only: " . s:DirDiffDiffOnlyLine

        bd

    " Now let's get the Differ string
    "echo "Getting the diff in GetDiffStrings"

    silent exe "!echo testdifferent > \"" . tmp2 . s:sep . "test" . "\""
    silent exe "!" . g:DirDiffLangString . "diff -r --brief \"" . tmp1 . "\" \"" . tmp2 . "\" > \"" . tmpdiff . "\""

    silent exe "split ". fnameescape(tmpdiff)
    let s:DirDiffDifferLine = substitute( getline(1), tmp1rx . ".*$", "", '')
    " Note that the diff on cygwin may output '/' instead of '\' for the
    " separator, so we need to accomodate for both cases
    let andrx = "^.*" . tmp1rx . "[\\\/]test\\(.*\\)" . tmp2rx . "[\\\/]test.*$"
    let endrx = "^.*" . tmp1rx . "[\\\/]test.*" . tmp2rx . "[\\\/]test\\(.*$\\)"
    "echo "andrx : " . andrx
    "echo "endrx : " . endrx
    let s:DirDiffDifferAndLine = substitute( getline(1), andrx , "\\1", '')
    let s:DirDiffDifferEndLine = substitute( getline(1), endrx, "\\1", '')

    "echo "s:DirDiffDifferLine = " . s:DirDiffDifferLine
    "echo "s:DirDiffDifferAndLine = " . s:DirDiffDifferAndLine
    "echo "s:DirDiffDifferEndLine = " . s:DirDiffDifferEndLine

    q

    " Delete tmp files
    "echo "Deleting tmp files."

    call <SID>Delete(tmp1)
    call <SID>Delete(tmp2)
    call <SID>Delete(tmpdiff)

    "avoid get diff text again
    let g:DirDiffTextOnlyInCenter = s:DirDiffDiffOnlyLineCenter
    let g:DirDiffTextOnlyIn       = s:DirDiffDiffOnlyLine
    let g:DirDiffTextFiles        = s:DirDiffDifferLine
    let g:DirDiffTextAnd          = s:DirDiffDifferAndLine
    let g:DirDiffTextDiffer       = s:DirDiffDifferEndLine
    let g:DirDiffDynamicDiffText  = 0

endfunction


"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
" vim: set sw=4:
