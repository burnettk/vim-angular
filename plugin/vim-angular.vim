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
  \   ' proprietary attribute "ui-view',
  \   '<div> proprietary attribute "src'
  \ ]
