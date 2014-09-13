require "spec_helper"

describe "alternate" do

  before do
    assume_blank_vimrc_by_unsetting_any_global_variables
  end

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

  specify "pairs that should work when test directory is configured by user" do
    assume_vimrc 'let g:angular_test_directory = "test/units"'

    should_alternate_between('app/js/poo.js', 'test/units/poo.js')
    should_alternate_between('app/js/poo.js', 'test/units/poo.spec.js')
    should_alternate_between('app/js/poo.js', 'test/units/pooSpec.js')

    should_alternate_between('app/src/poo.js', 'test/units/poo.js')
    should_alternate_between('app/src/poo.js', 'test/units/poo.spec.js')
    should_alternate_between('app/src/poo.js', 'test/units/pooSpec.js')
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
