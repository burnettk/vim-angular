require "spec_helper"

describe "runspec" do

  specify "html tidy syntastic ignores" do
    value_of_variable = vim.echo('g:syntastic_html_tidy_ignore_errors')
    value_of_variable.should include(
      ' proprietary attribute "ng-',
      ' proprietary attribute "ui-',
      '<div> proprietary attribute "src',
      'trimming empty <select>'
    )
  end

  specify "html tidy syntastic tags" do
    value_of_variable = vim.echo('g:syntastic_html_tidy_blocklevel_tags')
    value_of_variable.should include(
      'ng-include',
      'ng-form'
    )
  end

  specify "command with one spec" do
    write_file('test.js', <<-EOF)
      it('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF

    vim.edit 'test.js'
    vim.command 'AngularRunSpec'
    #vim.write # the AngularRunSpec writes the file

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      iit('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF
  end

  specify "command with two specs" do
    write_file('test.js', <<-EOF)
      it('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      it('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF

    vim.edit 'test.js'
    vim.normal '5j'
    vim.command 'AngularRunSpec'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      it('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      iit('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF
  end

  specify "command untoggles spec" do
    write_file('test.js', <<-EOF)
      iit('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      it('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF

    vim.edit 'test.js'
    vim.command 'AngularRunSpec'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      it('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      it('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF
  end

  specify "command grabs focus away from another spec" do
    write_file('test.js', <<-EOF)
      iit('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      it('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF

    vim.edit 'test.js'
    vim.normal '5j'
    vim.command 'AngularRunSpec'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      it('should work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });

      iit('should also work', function() {
        var actualThing = 'cow';
        expect(actualThing).toEqual('cow');
      });
    EOF
  end

  specify "command runs describe block" do
    write_file('test.js', <<-EOF)
      describe('aThing', function() {
        it('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF

    vim.edit 'test.js'
    vim.command 'AngularRunSpecBlock'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      ddescribe('aThing', function() {
        it('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF
  end

  specify "command to run describe block clears out any focused specs marked iit" do
    write_file('test.js', <<-EOF)
      describe('aThing', function() {
        iit('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF

    vim.edit 'test.js'
    vim.command 'AngularRunSpecBlock'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      ddescribe('aThing', function() {
        it('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF
  end

  specify "command toggles describe blocks and it specs" do
    write_file('test.js', <<-EOF)
      ddescribe('aThing', function() {
        it('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF

    vim.edit 'test.js'
    vim.command 'AngularRunSpecBlock'

    IO.read('test.js').strip.should eq normalize_string_indent(<<-EOF)
      describe('aThing', function() {
        it('should work', function() {
          var actualThing = 'cow';
          expect(actualThing).toEqual('cow');
        });
      });
    EOF
  end

end
