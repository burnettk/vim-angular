" angular.vim
" Maintainer:	Kevin Burnett
" Last Change: 2014 April 6


" https://github.com/scrooloose/syntastic/issues/612#issuecomment-19456342
"
" define your own proprietary attributes before this plugin loads, in your
" .vimrc, like so:
" let g:syntastic_html_tidy_ignore_errors = [' proprietary attribute "myhotcompany-']
"
" or copy the mechanism used here to ensure you get both your ignores and
" the plugin's ignores.
if !exists('g:syntastic_html_tidy_ignore_errors')
  let g:syntastic_html_tidy_ignore_errors = []
endif

let g:syntastic_html_tidy_ignore_errors = g:syntastic_html_tidy_ignore_errors + [
  \   ' proprietary attribute "ng-',
  \   ' proprietary attribute "ui-',
  \   '<ng-include> is not recognized!',
  \   'discarding unexpected <ng-include>',
  \   'discarding unexpected </ng-include>',
  \   '<div> proprietary attribute "src'
  \ ]


if !exists('g:angular_find_ignore')
  let g:angular_find_ignore = []
endif

let g:angular_find_ignore = g:angular_find_ignore + [
  \ 'coverage/',
  \ 'build/',
  \ 'dist/',
  \ 'test/',
  \ '.git/'
  \ ]

" Helper
" Find file in or below current directory and edit it.
function! s:Find(...) abort
  let path="."
  let query=a:1

  if a:0 == 2
    let cmd=a:2
  else
    let cmd="open"
  endif


  if !exists("g:angular_find_ignore")
    let ignore = ""
  else
    let ignore = " | egrep -v '".join(g:angular_find_ignore, "|")."'"
  endif

  let l:command="find ".path." -type f -iname '*".query."*'".ignore
  let l:list=system(l:command)
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))

  if l:num < 1
    echo "angular.vim says: '".query."' not found"
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


" Helper
" jacked from abolish.vim (was s:snakecase there). thank you, tim pope.
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

  let l:wordundercursor = expand('<cword>')
  let l:dashcased = s:dashcase(l:wordundercursor)
  let l:filethatmayexist = l:dashcased . '.js'

  if exists('g:angular_filename_convention') && (g:angular_filename_convention == 'camelcased' || g:angular_filename_convention == 'titlecased')
    call <SID>Find(l:wordundercursor . '.js', a:cmd)
  else
    call <SID>Find(l:filethatmayexist, a:cmd)
  endif
endfunction

function! s:SubStr(originalstring, pattern, replacement) abort
  return substitute(a:originalstring, a:pattern, a:replacement, "")
endfunction

function! s:GenerateTestPaths(currentpath, appbasepath, testbasepath) abort
  let l:samefilename = s:SubStr(a:currentpath, a:appbasepath, a:testbasepath)
  let l:withcamelcasedspecsuffix = s:SubStr(s:SubStr(a:currentpath, a:appbasepath, a:testbasepath), ".js", "Spec.js")
  let l:withdotspecsuffix = s:SubStr(s:SubStr(a:currentpath, a:appbasepath, a:testbasepath), ".js", ".spec.js")
  return [l:samefilename, l:withcamelcasedspecsuffix, l:withdotspecsuffix]
endfunction

function! s:GenerateSrcPaths(currentpath, appbasepath, testbasepath) abort
  return [s:SubStr(s:SubStr(a:currentpath, a:testbasepath, a:appbasepath), "Spec.js", ".js"),
        \ s:SubStr(s:SubStr(a:currentpath, a:testbasepath, a:appbasepath), ".spec.js", ".js")]
endfunction

function! s:Alternate(cmd) abort
  let l:currentpath = expand('%')
  let l:possiblepathsforalternatefile = []
  for possiblenewpath in [s:SubStr(l:currentpath, ".js", "_test.js"), s:SubStr(l:currentpath, "_test.js", ".js")]
    if possiblenewpath != l:currentpath
      let l:possiblepathsforalternatefile = [possiblenewpath]
    endif
  endfor

  if exists('g:angular_source_directory')
    let l:possiblesrcpaths = [g:angular_source_directory]
  else
    let l:possiblesrcpaths = ['app/src', 'app/js', 'app/scripts', 'public/js', 'frontend/src']
  endif

  if exists('g:angular_test_directory')
    let l:possibletestpaths = [g:angular_test_directory]
  else
    let l:possibletestpaths = ['test/unit', 'test/spec', 'test/karma/unit', 'tests/frontend']
  endif

  for srcpath in l:possiblesrcpaths
    if l:currentpath =~ srcpath
      for testpath in l:possibletestpaths
        let l:possiblepathsforalternatefile = l:possiblepathsforalternatefile + s:GenerateTestPaths(l:currentpath, srcpath, testpath)
      endfor
    endif
  endfor

  for testpath in l:possibletestpaths
    if l:currentpath =~ testpath
      for srcpath in l:possiblesrcpaths
        let l:possiblepathsforalternatefile = l:possiblepathsforalternatefile + s:GenerateSrcPaths(l:currentpath, srcpath, testpath)
      endfor
    endif
  endfor

  for path in l:possiblepathsforalternatefile
    if filereadable(path)
      return a:cmd . ' ' . fnameescape(path)
    endif
  endfor

  return 'echoerr '.string("angular.vim says: Couldn't find alternate file")
endfunction


" Helper
" goes to end of line first ($) so it doesn't go the previous
" function if your cursor is sitting right on top of the pattern
function! s:SearchUpForPattern(pattern) abort
  execute 'silent normal! ' . '$?' . a:pattern . "\r"
endfunction

function! s:FirstLetterOf(sourcestring) abort
  return strpart(a:sourcestring, 0, 1)
endfunction

function! s:AngularRunSpecOrBlock(jasminekeyword) abort
  " save cursor position so we can go back
  let b:angular_pos = getpos('.')

  cal s:SearchUpForPattern(a:jasminekeyword . '(')

  let l:wordundercursor = expand('<cword>')
  let l:firstletter = s:FirstLetterOf(a:jasminekeyword)

  if l:wordundercursor == a:jasminekeyword
    " if there was a spec (anywhere in the file) highlighted with "iit" before, revert it to "it"
    let l:positionofspectorun = getpos('.')

    " this can move the cursor, hence setting the cursor back
    %s/ddescribe/describe/ge
    %s/iit/it/ge

    " move cursor back to the spec we want to run
    call setpos('.', l:positionofspectorun)

    " either change the current spec to "iit" or
    " the current block to "ddescribe"
    execute 'silent normal! cw' . l:firstletter . a:jasminekeyword
  elseif l:wordundercursor == l:firstletter . a:jasminekeyword
    " either delete the second i in "iit" or
    " the second d in "ddescribe"
    execute 'silent normal! x'
  endif

  update " write the file if modified

  " Reset cursor to previous position.
  call setpos('.', b:angular_pos)
endfunction

function! s:AngularRunSpecBlock() abort
  cal s:AngularRunSpecOrBlock('describe')
endfunction

function! s:AngularRunSpec() abort
  cal s:AngularRunSpecOrBlock('it')
endfunction


nnoremap <silent> <Plug>AngularGfJump :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('open')<CR>
nnoremap <silent> <Plug>AngularGfSplit :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('split')<CR>
nnoremap <silent> <Plug>AngularGfTabjump :<C-U>exe <SID>FindFileBasedOnAngularServiceUnderCursor('tabedit')<CR>

augroup angular_gf
  autocmd!
  autocmd FileType javascript,html command! -buffer AngularGoToFile :call s:FindFileBasedOnAngularServiceUnderCursor('open')
  autocmd FileType javascript,html nmap <buffer> gf          <Plug>AngularGfJump
  autocmd FileType javascript,html nmap <buffer> <C-W>f      <Plug>AngularGfSplit
  autocmd FileType javascript,html nmap <buffer> <C-W><C-F>  <Plug>AngularGfSplit
  autocmd FileType javascript,html nmap <buffer> <C-W>gf     <Plug>AngularGfTabjump
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
  autocmd FileType javascript command! -buffer AngularRunSpecBlock :call s:AngularRunSpecBlock()
  autocmd FileType javascript nnoremap <silent><buffer> <Leader>rs  :AngularRunSpec<CR>
  autocmd FileType javascript nnoremap <silent><buffer> <Leader>rb  :AngularRunSpecBlock<CR>
augroup END
