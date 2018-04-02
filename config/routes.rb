Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses/learn' => 'analyses#learn'

  namespace :api do
    resources :analyses, :only => [] do
      get '/training_data' => 'analyses#download_training_data'
    end
  end
end
