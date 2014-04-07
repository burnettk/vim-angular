require "spec_helper"

describe "alternate" do

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

  specify "pairs that should work" do
    should_alternate_between('app/src/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/src/poo.js', 'test/unit/pooSpec.js')
    should_alternate_between('app/js/poo.js', 'test/unit/poo.js')
    should_alternate_between('app/js/poo.js', 'test/unit/pooSpec.js')
    should_alternate_between('public/js/controllers/piles.js', 'test/karma/unit/controllers/piles.spec.js')
  end

  specify "pairs should not always work" do
    file_a = 'app/junk/poo.js'
    file_b = 'test/unit/poo.js'
    setup_filesystem(file_a, file_b)
    vim.edit file_a
    vim.command 'A'
    current_file_name.should eq file_a
  end
end

