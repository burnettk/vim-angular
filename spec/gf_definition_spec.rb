require "spec_helper"

describe "gf definition" do

  before do
    assume_blank_vimrc_by_unsetting_any_global_variables
  end

  specify "should be found even though the identifier does not include the js suffix that is obviously in the filename" do
    setup_filesystem('app/js/poo.js')
    find_definition('poo')
    current_file_name.should eq "./app/js/poo.js"
  end

  specify "should be found when the identifier has a camelcasedName" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('pilesOfPoo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

  specify "should be found when the identifier has a TitlecasedName" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('PilesOfPoo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

  specify "should be found when the filename-is-dasherized" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('pilesOfPoo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

  specify "should be found when the filenameIsCamelcased" do
    setup_filesystem('app/js/pilesOfPoo.js')
    find_definition('pilesOfPoo')
    current_file_name.should eq "./app/js/pilesOfPoo.js"
  end

  specify "should be found when the FilenameIsTitlecased" do
    setup_filesystem('app/js/PilesOfPoo.js')
    find_definition('PilesOfPoo')
    current_file_name.should eq "./app/js/PilesOfPoo.js"
  end

  specify "should be a champ about avoiding full stops" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('PilesOfPoo.keepingStinking()')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

  specify "should find partial matches at the end i guess" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('poo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

private

  def find_definition(string_to_find_by)
    write_file('starting-file.js', <<-EOF)
      #{string_to_find_by}
    EOF

    vim.edit 'starting-file.js'
    current_file_name.should eq "starting-file.js"
    vim.command 'AngularGoToFile'
  end

end
