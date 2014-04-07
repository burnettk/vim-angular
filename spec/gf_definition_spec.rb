require "spec_helper"

describe "gf definition" do

  def find_definition(string_to_find_by)
    write_file('starting-file.js', <<-EOF)
      #{string_to_find_by}
    EOF

    vim.edit 'starting-file.js'
    current_file_name.should eq "starting-file.js"
    vim.command 'AngularGoToFile'
  end

  specify "should be found by same name but without js" do
    setup_filesystem('app/js/poo.js')
    find_definition('poo')
    current_file_name.should eq "./app/js/poo.js"
  end

  specify "should be found by camelizedName" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('pilesOfPoo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
  end

  specify "should be found by TitlecasedName" do
    setup_filesystem('app/js/piles-of-poo.js')
    find_definition('PilesOfPoo')
    current_file_name.should eq "./app/js/piles-of-poo.js"
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
end

