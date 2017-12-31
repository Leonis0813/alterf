Resque.redis = Redis.new(host: 'localhost', port: 6379)
Resque.before_fork = -> _job { ActiveRecord::Base.connection.disconnect! }
Resque.after_fork  = -> _job { ActiveRecord::Base.establish_connection }
