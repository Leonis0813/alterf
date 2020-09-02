# This file is used by Rack-based servers to start the application.

require 'unicorn/worker_killer'
use Unicorn::WorkerKiller::MaxRequests, 500, 1000, true
use Unicorn::WorkerKiller::Oom, (512*(1024**2)), (1024*(1024**2), 16, true)

require ::File.expand_path('../config/environment', __FILE__)
map ActionController::Base.config.relative_url_root || '/' do
  run Rails.application
end
