namespace :analysis do
  require File.expand_path('../../../config/application', __FILE__)

  desc 'Start learning'
  task :learn, [:num_training_data, :num_tree, :num_feature] => :environment do |task, args|
    system "cd #{Rails.root}/scripts;" +
           "Rscript analyze/learn.r #{args.num_training_data} #{args.num_tree} #{args.num_feature}"
  end

  desc 'Start predicting'
  task :predict, [:model, :test_data] => :environment do |task, args|
    system "cd #{Rails.root}/scripts;" +
           "Rscript analyze/predict.r #{args.model} #{args.test_data}"
  end
end
