require "spec_helper"

describe "alternate" do

  before do
    assume_blank_vimrc_by_unsetting_any_global_variables
  end

  # g:angular_skip_alternate_mappings is used at angular.vim load
  # time, so it's not as simple as this to test it.
  # specify "should allow user to disable alternates" do
  #   assume_vimrc('let g:angular_skip_alternate_mappings = "true"')
  #   file_a = 'app/src/poo.js'
  #   file_b = 'test/unit/poo.js'
  #   setup_filesystem(file_a, file_b)
  #   vim.edit file_a
  #   vim.command 'A'
  #   current_file_name.should eq file_a
  # end

  specify "pairs that should work" do
    should_alternate_between('app/src/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/src/poo.js', 'test/unit/poo.spec.js')
    should_alternate_between('app/src/poo.js', 'test/unit/pooSpec.js')

    should_alternate_between('app/src/poo.js', 'test/spec/poo.js')
    should_alternate_between('app/src/poo.js', 'test/spec/poo.spec.js')
    should_alternate_between('app/src/poo.js', 'test/spec/pooSpec.js')

    should_alternate_between('app/js/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/js/poo.js', 'test/unit/poo.spec.js')
    should_alternate_between('app/js/poo.js', 'test/unit/pooSpec.js')

    should_alternate_between('app/js/poo.js', 'test/spec/poo.js')
    should_alternate_between('app/js/poo.js', 'test/spec/poo.spec.js')
    should_alternate_between('app/js/poo.js', 'test/spec/pooSpec.js')

    should_alternate_between('app/foo/foo.controller.js', 'app/foo/test/foo.controller.spec.js')
    should_alternate_between('app/bar/bar.service.js', 'app/bar/test/bar.service.spec.js')

    should_alternate_between('app/scripts/controllers/poo.js', 'test/spec/controllers/poo.js') # yoeman
    should_alternate_between('public/js/controllers/piles.js', 'test/karma/unit/controllers/piles.spec.js') # mean framework
    should_alternate_between('frontend/src/poo.js', 'tests/frontend/poo.spec.js') # Pull Request 6 supporting nkoehring's convention

    should_alternate_between('app/components/pane/pane-directive.js', 'app/components/pane/pane-directive_test.js') # "Best Practice Recommendations for Angular App Structure" convention
  end

  specify "pairs that should work when src directory is configured by user" do
    assume_vimrc 'let g:angular_source_directory = "WebContent/js"'

    should_alternate_between('WebContent/js/poo.js', 'test/unit/poo.js')
    should_alternate_between('WebContent/js/poo.js', 'test/unit/poo.spec.js')
    should_alternate_between('WebContent/js/poo.js', 'test/unit/pooSpec.js')

    should_alternate_between('WebContent/js/poo.js', 'test/spec/poo.js')
    should_alternate_between('WebContent/js/poo.js', 'test/spec/poo.spec.js')
    should_alternate_between('WebContent/js/poo.js', 'test/spec/pooSpec.js')
  end

  specify "with multiple src directories configured by user" do
    assume_vimrc 'let g:angular_source_directory = ["WebContent/js", "app/src"]'

    should_alternate_between('WebContent/js/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/src/poo.js', 'test/unit/pooSpec.js')
  end

  specify "pairs that should work when one test directory is configured by user" do
    assume_vimrc 'let g:angular_test_directory = "test/units"'

    should_alternate_between('app/js/poo.js', 'test/units/poo.js')
    should_alternate_between('app/js/poo.js', 'test/units/poo.spec.js')
    should_alternate_between('app/js/poo.js', 'test/units/pooSpec.js')

    should_alternate_between('app/src/poo.js', 'test/units/poo.js')
    should_alternate_between('app/src/poo.js', 'test/units/poo.spec.js')
    should_alternate_between('app/src/poo.js', 'test/units/pooSpec.js')
  end

  specify "with multiple test directories configured by user" do
    assume_vimrc 'let g:angular_test_directory = ["test/unit", "test/spec"]'

    should_alternate_between('app/js/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/src/poo.js', 'test/spec/pooSpec.js')
  end

  # https://github.com/burnettk/vim-angular/issues/22
  specify "pairs that should work when source and test directories configured by user" do
    assume_vimrc 'let g:angular_source_directory = "app/assets/javascripts/angular"'
    assume_vimrc 'let g:angular_test_directory = "spec/javascripts/angular"'

    should_alternate_between('app/assets/javascripts/angular/foos/index.controller.js', 'spec/javascripts/angular/foos/index.controller.spec.js')

    # coffee currently not supported. pull requests welcome.
    # should_alternate_between('app/assets/javascripts/angular/foos/index.controller.js.coffee', 'spec/javascripts/angular/foos/index.controller.spec.js.coffee')
  end

  specify "pairs should not all work" do
    file_a = 'app/junk/poo.js'
    file_b = 'test/unit/poo.js'
    setup_filesystem(file_a, file_b)
    vim.edit file_a
    vim.command 'A'
    current_file_name.should eq file_a
  end

private

  def should_alternate_from_a_to_b(file_a, file_b)
    vim.edit file_a
    current_file_name.should eq file_a
    vim.command 'A'
    current_file_name.should eq file_b
  end

  def should_alternate_between(file_a, file_b)
    code_path = file_a
    test_path = file_b
    setup_filesystem(code_path, test_path)
    should_alternate_from_a_to_b(code_path, test_path)
    should_alternate_from_a_to_b(test_path, code_path)
    FileUtils.rm(file_a)
    FileUtils.rm(file_b)
  end

end
