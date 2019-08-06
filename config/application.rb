require File.expand_path('boot', __dir__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module Alterf
  class Application < Rails::Application
    config.i18n.default_locale = :ja
    config.active_job.queue_adapter = :resque
    config.autoload_paths += [
      "#{config.root}/lib/clients",
      "#{config.root}/lib/errors",
      "#{config.root}/lib/utils",
    ]
  end
end
