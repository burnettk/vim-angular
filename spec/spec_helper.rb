require 'vimrunner'
require 'vimrunner/rspec'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  config.start_vim do
    vim = Vimrunner.start#_gvim
    plugin_path = File.expand_path('../..', __FILE__)
    vim.prepend_runtimepath(plugin_path) # so the ftplugin behavior takes effect
    vim.add_plugin(plugin_path, 'plugin/vim-angular.vim')
    vim.add_plugin(plugin_path, 'ftplugin/javascript.vim')
    vim
  end
end
