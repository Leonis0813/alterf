namespace :resque do
  namespace :worker do
    require File.expand_path('../../../config/application', __FILE__)

    task :start do
      worker :start
    end

    task :stop do
      worker :stop
    end

    task :restart do
      worker :restart
    end
  end

  def worker(operation)
    system "#{Rails.root}/bin/resque_worker #{operation}"
  end
end
