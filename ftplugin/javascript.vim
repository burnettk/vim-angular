" Vim filetype plugin
" Language:	JavaScript
" Maintainer:	Kevin Burnett
" Last Change: 2014 March 21

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim


let &cpo = s:cpo_save
unlet s:cpo_save


if exists("g:did_vim_angular_ftplugin_functions")
  finish
endif
let g:did_vim_angular_ftplugin_functions = 1

function SwitchToAlternateFile()
  let l:currentpath = expand('%')
  let l:newpath = ""

  if l:currentpath =~ "test/unit"
    let l:newpath = substitute(l:currentpath, "test/unit", "app/src", "")
  elseif l:currentpath =~ "app/src"
    let l:newpath = substitute(l:currentpath, "app/src", "test/unit", "")
  endif

  if l:newpath != "" && filereadable(l:newpath)
    execute 'edit ' . l:newpath
  endif
endfunction

command -nargs=0 A call SwitchToAlternateFile()

let g:FindIgnore = ['coverage/', 'test/', '.git']

" Find file in current directory and edit it.
function! Find(...)
    let path="."
    let query=a:1

    if a:0 == 2
        let cmd=a:2
    else
        let cmd="open"
    endif


    if !exists("g:FindIgnore")
        let ignore = ""
    else
        let ignore = " | egrep -v '".join(g:FindIgnore, "|")."'"
    endif

    let l:command="find ".path." -type f -iname '*".query."*'".ignore
    let l:list=system(l:command)
    let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))

    if l:num < 1
        echo "'".query."' not found"
        return
    endif

    if l:num == 1
        exe cmd . " " . substitute(l:list, "\n", "", "g")
    else
        let tmpfile = tempname()
        exe "redir! > " . tmpfile
        silent echon l:list
        redir END
        let old_efm = &efm
        set efm=%f

        if exists(":cgetfile")
            execute "silent! cgetfile " . tmpfile
        else
            execute "silent! cfile " . tmpfile
        endif

        let &efm = old_efm

        " Open the quickfix window below the current window
        botright copen

        call delete(tmpfile)
    endif
    "echom l:command
endfunction

command! -nargs=* Find :call Find(<f-args>)

" jacked from abolish.vim (s:snakecase). thank you, tim pope.
function! s:dashcase(word)
  let word = substitute(a:word,'::','/','g')
  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
  let word = substitute(word,'_','-','g')
  let word = tolower(word)
  return word
endfunction


function! s:GF(cmd, file) abort
endfunction

function! FindFileBasedOnAngularServiceUnderCursor(cmd)
  let l:thingundercursor = expand('<cfile>')
  if l:thingundercursor =~ "/"
    execute "e<cfile>"
    return
  endif
  let l:dashcased = s:dashcase(l:thingundercursor)
  "echo l:dashcased
  let l:filethatmayexist = l:dashcased . ".js"
  "let l:filethatmayexist = printf("%.js", tolower(l:dashcased))
  "echo l:filethatmayexist
  execute "Find " . l:filethatmayexist . " " . a:cmd
endfunction

augroup vim_angular_go_to_file
  autocmd!
  autocmd FileType javascript nnoremap <silent><buffer> gf         :<C-U>exe FindFileBasedOnAngularServiceUnderCursor("open")<CR>
  autocmd FileType javascript nnoremap <silent><buffer> <C-W>f     :<C-U>exe FindFileBasedOnAngularServiceUnderCursor("split")<CR>
  autocmd FileType javascript nnoremap <silent><buffer> <C-W><C-F> :<C-U>exe FindFileBasedOnAngularServiceUnderCursor("split")<CR>
  autocmd FileType javascript nnoremap <silent><buffer> <C-W>gf    :<C-U>exe FindFileBasedOnAngularServiceUnderCursor("tabedit")<CR>
augroup END

" vim:set sw=2:

