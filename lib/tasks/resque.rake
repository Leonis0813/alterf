namespace :resque do
  namespace :worker do
    require File.expand_path('../../config/application', __dir__)

    desc 'Start rescue'
    task :start do
      worker :start
    end

    desc 'Stop rescue'
    task :stop do
      worker :stop
    end

    desc 'Restart rescue'
    task :restart do
      worker :restart
    end
  end

  def worker(operation)
    system "#{Rails.root}/bin/resque_worker #{operation}"
  end
end
