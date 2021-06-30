require File.expand_path('boot', __dir__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
Bundler.require(*Rails.groups)

module Alterf
  class Application < Rails::Application
    config.generators.javascript_engine = :js
    config.i18n.default_locale = :ja
    config.active_job.queue_adapter = :resque
    config.paths.add 'lib/clients', eager_load: true
    config.paths.add 'lib/errors', eager_load: true
    config.paths.add 'lib/utils', eager_load: true
  end
end
