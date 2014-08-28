require "spec_helper"

describe "gf file" do

  specify "default behavior for directive" do
    html_file_at('my-customer.html')
    do_gf_from_directive_that_references!('my-customer.html')
    current_file_name.should eq "my-customer.html"
  end

  specify "default behavior for view" do
    html_file_at('my-customer.html')
    do_gf_from_view_that_references!('my-customer.html')
    current_file_name.should eq "my-customer.html"
  end

  specify "when html in app/templates and directive references full path" do
    html_file_at('app/templates/my-customer.html')
    do_gf_from_directive_that_references!('app/templates/my-customer.html')
    current_file_name.should eq "app/templates/my-customer.html"
  end

  specify "when html in app/templates and directive references path minus app" do
    html_file_at('app/templates/my-customer.html')
    do_gf_from_directive_that_references!('templates/my-customer.html')
    current_file_name.should eq "app/templates/my-customer.html"
  end

  specify "when html in app/templates and view references path minus app" do
    html_file_at('app/templates/my-customer.html')
    do_gf_from_view_that_references!('templates/my-customer.html')
    current_file_name.should eq "app/templates/my-customer.html"
  end

  specify "when html in app/views and view references path minus app" do
    html_file_at('app/views/my-customer.html')
    do_gf_from_view_that_references!('views/my-customer.html')
    current_file_name.should eq "app/views/my-customer.html"
  end

  specify "when html in app subdirectory and directive references path minus app" do
    html_file_at('app/my-customer.html')
    do_gf_from_directive_that_references!('my-customer.html')
    current_file_name.should eq "app/my-customer.html"
  end

  specify "when html in random unsupported subdirectory that directive is not referencing" do
    html_file_at('wut/my-customer.html')
    do_gf_from_directive_that_references!('my-customer.html')
    current_file_name.should eq "directive.js"
  end

  specify "the gelus use case from github issue #4" do
    html_file_at('partials/widgets/clustering-widget.html')
    do_gf_from_directive_that_references!('partials/widgets/clustering-widget.html', 'clustering')
    current_file_name.should eq "partials/widgets/clustering-widget.html"
  end

private

  def html_file_at(filename)
    safe_write_file(filename)
  end

  def do_gf(starting_file, starting_file_contents, search_term = default_search_term)
    write_file(starting_file, starting_file_contents)

    vim.edit starting_file
    current_file_name.should eq starting_file
    vim.normal "/#{search_term}<CR>"
    # vim.normal 'gf' # does not pick up some aspect of setting up this mapping in the autocmd
    vim.command 'AngularGoToFile'
  end

  def default_search_term
    'my-cust'
  end

  def do_gf_from_directive_that_references!(template_url, search_term = default_search_term)
    starting_file = 'directive.js'

    directive_file_contents = <<-EOF
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

    do_gf(starting_file, directive_file_contents, search_term)
  end

  def do_gf_from_view_that_references!(template_url)
    starting_file = 'hot.html'

    do_gf(starting_file, <<-EOF)
      <div class="totally-awesome"
        ng-if="readyToRock"
        ng-include src="'#{template_url}'">
      </div
    EOF
  end

end
