# angular.vim

Some niceties for using vim with the AngularJS framework.

## Features

### Switch to test file and vice versa

    :A

A, the "alternate" file, has been mapped to take you from your code to the
corresponding test file, or from your test file to the corresponding
implementation file. For example, if you're in app/js/rock-socks.js, and 
you hammer :A, you will be taken to test/spec/rock-socks.js, if such a file
exists. Some other common directory structure conventions in the angular 
community, such as app/src and test/unit, are also supported. Feel free to 
file a pull request if your reasonable convention doesn't work.

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
useful in the context of an angular app, since html fragments are specified
as file paths in views (with ng-include src="full/path.html), directives
(with templateUrl: 'src/myapp/modules/main/views//prompt-list.html', so an
attempt has been made to allow this to work as well. If all that is missing
from a template path is the "app" directory (which is a common value for
"cwd" in `Gruntfile.js`, the plugin will add this for you as well. If either
of these two things don't work for your use case, file a ticket, figure
out why and file a pull request, or [use ctags][ctags].

### Run the current spec

If you're writing jasmine unit tests for your angular app, they look like
this:

```javascript
it('should work', function() {
  var actualThing = 'cow';
  expect(actualThing).toEqual('cow');
});

```

Now, if you take that "it" prefix, and replace it with "iit", instead of
running your entire suite, it will run JUST THAT ONE SPEC. There are
probably bad reasons to want to do this, like if your build is broken
and you only want to fix your code, but it can be pretty handy to
focus in on just one spec at a time (and one spec generally runs way fast).

So, if you're anywhere inside a spec:

    :AngularRunSpec
    
or the "go run spec" mapping:

    grs
    
will toggle the spec between "it" and "iit." This works especially well if
you have a karma watch going. See the [screencast][screencast].

### Syntastic syntax checker ignores

You know how you use syntastic to check your syntax as you edit, because
it works for pretty much any language, and is awesome? When you use angular
directives (like ng-app, ng-repeat, and even library directives like
ui-view), the html tidy check will complain. This is fixed out of the box,
and you can use the same (syntastic) mechanism to add your own directives,
by specifying exclusions in your .vimrc like this:

```
let g:syntastic_html_tidy_ignore_errors = ['proprietary attribute "myhotcompany-']
```

## Installation

* Using [Pathogen][pathogen], run the following commands:

        % cd ~/.vim/bundle
        % git clone git://github.com//burnettk/vim-angular.git

* Using [Vundle][vundle], add the following to your `vimrc` then run
  `:BundleInstall`

        Bundle "burnettk/vim-angular"

Once help tags have been generated, and I have written the helpfile, you
can view the manual with
`:help angular`.

## Self-Promotion

Like vim-angular.vim? Follow the repository on
[GitHub](https://github.com/burnettk/vim-angular) and vote for it on
[vim.org](http://www.vim.org/scripts/script.php?script_id=FIXME).  And if
you're feeling especially charitable, follow [burnettk](http://notkeepingitreal.com) on
[Twitter](http://twitter.com/kbbkkbbk) and
[GitHub](https://github.com/burnettk).

## License

Copyright (c) Kevin Burnett.  Distributed under the same terms as Vim itself.
See `:help license`.

[ctags]: http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
[screencast]: http://notkeepingitreal.com
[pathogen]: https://github.com/tpope/vim-pathogen
[vundle]: https://github.com/gmarik/vundle
[github]: https://github.com/burnettk/vim-angular
