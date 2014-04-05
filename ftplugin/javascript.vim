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

function! s:Alternate(cmd) abort
  let l:currentpath = expand('%')
  let l:newpaths = []

  if l:currentpath =~ "test/unit"
    let l:newpaths = [
    \ substitute(l:currentpath, "test/unit", "app/js", ""),
    \ substitute(l:currentpath, "test/unit", "app/src", ""),
    \ substitute(substitute(l:currentpath, "test/unit", "app/js", ""), "Spec.js", ".js", ""),
    \ substitute(substitute(l:currentpath, "test/unit", "app/src", ""), "Spec.js", ".js", "")
    \ ]
  elseif l:currentpath =~ "app/src"
    let l:newpaths = [substitute(l:currentpath, "app/src", "test/unit", ""), substitute(substitute(l:currentpath, "app/src", "test/unit", ""), ".js", "Spec.js", "")]
  elseif l:currentpath =~ "app/js"
    let l:newpaths = [substitute(l:currentpath, "app/js", "test/unit", ""), substitute(substitute(l:currentpath, "app/js", "test/unit", ""), ".js", "Spec.js", "")]
  endif

  if l:newpaths != []
    for path in l:newpaths
      if filereadable(path)
        return a:cmd . ' ' . fnameescape(path)
      endif
    endfor
  endif

  return 'echoerr '.string("Couldn't find alternate file")
endfunction

let g:FindIgnore = ['coverage/', 'test/', '.git']

" Find file in current directory and edit it.
function! s:Find(...) abort
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
endfunction

" jacked from abolish.vim (s:snakecase). thank you, tim pope.
function! s:dashcase(word) abort
  let word = substitute(a:word,'::','/','g')
  let word = substitute(word,'\(\u\+\)\(\u\l\)','\1_\2','g')
  let word = substitute(word,'\(\l\|\d\)\(\u\)','\1_\2','g')
  let word = substitute(word,'_','-','g')
  let word = tolower(word)
  return word
endfunction


function! s:FindFileBasedOnAngularServiceUnderCursor(cmd) abort
  let l:fileundercursor = expand('<cfile>')

  " Maybe the person actually has the cursor over a file path.
  " do more standard gf stuff in that case
  if l:fileundercursor =~ "/"

    if filereadable(l:fileundercursor)
      execute "e " . l:fileundercursor
      return
    endif

    " app is the angular 'public root' conventionally.
    " this will help us find things like the template here:
    " $routeProvider.when('/view1', {templateUrl: 'partials/partial1.html', controller: 'MyCtrl1'});
    if filereadable("app/" . l:fileundercursor)
      execute "e " . "app/" . l:fileundercursor
      return
    endif

  endif

  let l:wordundercursor = expand('<cword>')
  let l:dashcased = s:dashcase(l:wordundercursor)
  let l:filethatmayexist = l:dashcased . ".js"

  call <SID>Find(l:filethatmayexist, a:cmd)
endfunction

" helper function. goes to end of line first ($) so it doesn't go the previous
" function if your cursor is sitting right on top of the pattern
function! s:SearchUpForPattern(pattern) abort
  execute 'silent normal! ' . '$?' . a:pattern . "\r"
endfunction

function! s:AngularRunSpec() abort
  " save cursor position so we can go back
  let b:angular_pos = getpos('.')

  cal s:SearchUpForPattern('it(')

  let l:wordundercursor = expand('<cword>')

  if l:wordundercursor == "it"
    " if there was a spec (anywhere in the file) highlighted with "iit" before, revert it to "it"
    let l:positionofspectorun = getpos('.')

    " this can move the cursor, hence setting the cursor back
    %s/iit/it/ge

    " move cursor back to the spec we want to run
    call setpos('.', l:positionofspectorun)

    " change the current spec to "iit"
    execute 'silent normal! cwiit'
  elseif l:wordundercursor == "iit"
    " delete the second i in "iit"
    execute 'silent normal! x'
  endif

  update " write the file if modified

  " Reset cursor to previous position.
  call setpos('.', b:angular_pos)
endfunction

nnoremap <silent> <Plug>AngularGfJump :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('open')<CR>
nnoremap <silent> <Plug>AngularGfSplit :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('split')<CR>
nnoremap <silent> <Plug>AngularGfTabjump :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('tabedit')<CR>

" consider also [d
" maybe keep gf fallback (for the app dir) in place
augroup angular_gf
  autocmd!
  autocmd FileType javascript nmap <buffer> gf          <Plug>AngularGfJump
  autocmd FileType javascript nmap <buffer> <C-W>f      <Plug>AngularGfSplit
  autocmd FileType javascript nmap <buffer> <C-W><C-F>  <Plug>AngularGfSplit
  autocmd FileType javascript nmap <buffer> <C-W>gf     <Plug>AngularGfTabjump
augroup END

augroup angular_alternate
  autocmd!
  autocmd FileType javascript command! -buffer -bar -bang A :exe s:Alternate('edit<bang>')
  autocmd FileType javascript command! -buffer -bar AS :exe s:Alternate('split')
  autocmd FileType javascript command! -buffer -bar AV :exe s:Alternate('vsplit')
  autocmd FileType javascript command! -buffer -bar AT :exe s:Alternate('tabedit')
augroup END

augroup angular_run_spec
  autocmd!
  autocmd FileType javascript command! -buffer AngularRunSpec :call s:AngularRunSpec()
  autocmd FileType javascript nnoremap <silent><buffer> <Leader>rs  :AngularRunSpec<CR>
augroup END

" vim:set sw=2:
