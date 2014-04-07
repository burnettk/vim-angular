require "spec_helper"

describe "gf file" do

  def html_file_at(filename)
    safe_write_file(filename)
  end

  def do_gf_from_directive!(template_url = 'my-customer.html')
    write_file('directive.js', <<-EOF)
    angular.module('docsTemplateUrlDirective', [])
      .controller('Controller', ['$scope', function($scope) {
        $scope.customer = {
          name: 'Naomi',
          address: '1600 Amphitheatre'
        };
      }])
      .directive('myCustomer', function() {
        return {
          templateUrl: '#{template_url}'
        };
      });
    EOF

    vim.edit 'directive.js'
    current_file_name.should eq "directive.js"
    vim.normal '/my-cust<CR>'
    #vim.normal 'gf'
    vim.command 'AngularGoToFile'
  end

  specify "default behavior" do
    html_file_at('my-customer.html')
    do_gf_from_directive!
    current_file_name.should eq "my-customer.html"
  end

  specify "when html in app/templates and directive references full path" do
    html_file_at('app/templates/my-customer.html')
    do_gf_from_directive!('app/templates/my-customer.html')
    current_file_name.should eq "app/templates/my-customer.html"
  end

  specify "when html in app/templates and directive references path minus app" do
    html_file_at('app/templates/my-customer.html')
    do_gf_from_directive!('templates/my-customer.html')
    current_file_name.should eq "app/templates/my-customer.html"
  end

  specify "when html in app subdirectory" do
    html_file_at('app/my-customer.html')
    do_gf_from_directive!
    current_file_name.should eq "app/my-customer.html"
  end

  specify "when html in random unsupported subdirectory" do
    html_file_at('wut/my-customer.html')
    do_gf_from_directive!
    current_file_name.should eq "directive.js"
  end

end
