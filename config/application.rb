require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Mailer42
  class Application < Rails::Application
  end
end
