# angular.vim

[![Build Status](https://travis-ci.org/burnettk/vim-angular.svg)](https://travis-ci.org/burnettk/vim-angular)

Some niceties for using Vim with the AngularJS framework. See the [screencast][screencast].

The [canonical "what editor should I use for Angular?" post][editorchoice]
pretty squarely lands on Webstorm/IntelliJ as the peoples' choice
(12 people), but Vim is right there tied for second place along with
NetBeans and Sublime (four people each as of April, 2014) in this
super-scientific analysis. And don't make me quote [Tim Pope][tpope] on
which editor is forever.

## Shoulders of giants

[The reddit "how do I make vim do angular?" post][reddit] is largely
summarized in the documentation that follows, but as folks pointed out,
Angular is just javascript and html, and vim
does really nicely with these already. These other plugins will
also make your life easier when working with angular projects:

 * [pangloss/vim-javascript][vim-javascript] - "Vastly improved Javascript indentation and syntax support in Vim."
 * [othree/javascript-libraries-syntax.vim][javascript-libraries-syntax.vim] - "Syntax for JavaScript libraries," including Angular. This is the hotness you want to autocomplete ng-repeat et al. in your html.
 * [matthewsimo/angular-vim-snippets][angular-vim-snippets] - "repo for UltiSnips & Snipmate for angular to be included as a submodule for use in your .vim directory." `ngfor<tab>` ftw. The [honza/vim-snippets][vim-snippets] plugin is one library you can use to make this and other library-specific snippets work.
 * [claco/jasmine.vim][jasmine.vim] - "Jasmine Plugin for Vim," making your unit testing experience more excellent
 * [scrooloose/syntastic.git][syntastic] - "Syntax checking hacks for vim": excellent syntax checking for everything, including javascript and html. Install jshint globally (`npm install -g jshint`) and syntastic will get to work checking your javascript the right way (if your project already has a .jshintrc for use with grunt, it will even use that).

So why was this plugin written at all? I'm glad you asked!

## Features

### Switch to test file and vice versa

    :A

A, the "alternate" file, has been mapped to take you from your code to the
corresponding test file, or from your test file to the corresponding
implementation file. For example, if you're in app/js/rock-socks.js, and
you hammer :A, you will be taken to test/spec/rock-socks.js, if such a file
exists. Some other common directory structure conventions in the angular
community, such as app/src and test/unit, are also supported.

If the convention you use doesn't work out of the box, you can specify your
source and/or test directory in your .vimrc like this:

```
let g:angular_source_directory = 'app/source'
let g:angular_test_directory = 'test/units'
```

If there is a common convention that you feel should really work out of
the box, feel free to file a pull request to make it work (please
include a test to prove that it works).

If you don't want to use the alternate functionality, set this before the
plugin loads:

```
let g:angular_skip_alternate_mappings = 1
```

### Jump to definition of service/directive/controller/etc

    gf

"Go to file" has been slightly overriden to take you to the definition of
the file under your cursor. If you're reading some code like this...

```javascript
if (true) {
  AwesomeService.changeStateBecauseMutationIsAwesome();
}
```

...and your cursor is on AwesomeService, and you hammer gf, if there is a
file called awesome-service.js somewhere in a subdirectory of your path,
you will be taken there. The default behavior of gf can also be quite
useful in the context of an angular app, since file paths appear in views
(with ng-include src="full/path.html) and directives (with templateUrl:
'src/myapp/modules/main/views//prompt-list.html', so an
attempt has been made to allow this to work as well. If all that is missing
from a template path is the "app" directory (which is a common value for
"cwd" in `Gruntfile.js`, the plugin will add this for you as well. If either
of these two things don't work for your use case, file a ticket, figure
out why and file a pull request, or [use ctags][ctags].

Results can be filtered by specifying exclusions in your .vimrc like this:

```
let g:angular_find_ignore = ['build/', 'dist/']
```

It does work in at least some cases regardless of whether your filenames are
dasherized (likeABoss or LikeABoss goes to like-a-boss.js), camelcased
(likeABoss.js), or titlecased (LikeABoss.js).

### Run the current spec

If you're writing jasmine unit tests for your angular app, they look like
this:

```javascript
it('should work', function() {
  var actualThing = 'cow';
  expect(actualThing).toEqual('cow');
});

```

Now, if you take that "it" prefix, and replace it with "fit", instead of
running your entire suite, it will run JUST THAT ONE SPEC. There are
probably bad reasons to want to do this, like if your build is broken
and you want to ignore the failures, but it can be pretty handy to
focus in on just one spec at a time (and one spec generally runs way fast).

So, if you're anywhere inside a spec:

    :AngularRunSpec

or the "run spec" mapping:

    <leader>rs

will toggle the spec between "it" and "fit." This works especially well if
you have a karma watch going, as shown in the [screencast][screencast].

You are able to do the same with a describe block using the run block command:

    :AngularRunSpecBlock

or the corresponding mapping:

    <leader>rb

If you're running jasmine 1 instead of jasmine 2, you will need to use iit and
ddescribe instead of fit and fdescribe. To make that happen, tell vim-angular
that you are using jasmine 1 in your .vimrc like this:

```
let g:angular_jasmine_version = 1
```

### Syntastic syntax checker customization

You know how you use syntastic to check your syntax as you edit, because
it works for pretty much any language and is awesome? When you use angular
directives (like ng-app, ng-repeat, and even library directives like
ui-view), the html tidy check will complain. This is fixed out of the box.

Use the same mechanism to make syntastic aware of your own directives by
specifying exclusions in your .vimrc like this:

```
let g:syntastic_html_tidy_ignore_errors = ['proprietary attribute "myhotcompany-']
```

Some angular directives can also be used as custom elements (i.e. ng-include,
ng-form). These are added to the list of allowed tags by default. In order
to make syntastic recognize your additional blocklevel tags define them in your
.vimrc before the plugin is loaded:

```
let g:syntastic_html_tidy_blocklevel_tags = ['myCustomTag']
```


## Installation

* Using [Pathogen][pathogen], run the following commands:

        % cd ~/.vim/bundle
        % git clone git://github.com/burnettk/vim-angular.git

* Using [Vundle][vundle], add the following to your `vimrc` and then run
  `:PluginInstall`

        Plugin 'burnettk/vim-angular'

Once help tags have been generated, you can view the manual with
`:help angular`.

## Self-Promotion

Like vim-angular.vim? Follow the repository on [GitHub][project] and vote
for it on [vim.org][vimorgscript].  And if you're feeling especially
charitable, follow [me][mysite] on [Twitter][mytwitter] and
[GitHub][mygithub].

## License

Copyright (c) Kevin Burnett.  Distributed under the same terms as Vim itself.
See `:help license`.

[editorchoice]: https://groups.google.com/forum/#!topic/angular/MvPSE0Gy1rs
[tpope]: https://github.com/tpope
[reddit]: http://www.reddit.com/r/vim/comments/1q10an/recommended_vim_pluginssetup_for_angular/
[vim-javascript]: https://github.com/pangloss/vim-javascript
[javascript-libraries-syntax.vim]: https://github.com/othree/javascript-libraries-syntax.vim
[angular-vim-snippets]: https://github.com/matthewsimo/angular-vim-snippets
[vim-snippets]: https://github.com/honza/vim-snippets
[jasmine.vim]: https://github.com/claco/jasmine.vim
[syntastic]: https://github.com/scrooloose/syntastic
[ctags]: http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
[screencast]: http://youtu.be/-tEaY7HsTn8
[pathogen]: https://github.com/tpope/vim-pathogen
[vundle]: https://github.com/gmarik/vundle
[project]: https://github.com/burnettk/vim-angular
[vimorgscript]: http://www.vim.org/scripts/script.php?script_id=4907
[mysite]: http://notkeepingitreal.com
[mytwitter]: http://twitter.com/kbbkkbbk
[mygithub]: https://github.com/burnettk
