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

" vim:set sw=2:
