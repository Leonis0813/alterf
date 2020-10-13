Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses' => 'analyses#execute'
  resources :analyses, only: %i[show], param: :analysis_id

  get '/predictions' => 'predictions#manage'
  post '/predictions' => 'predictions#execute'

  get '/evaluations' => 'evaluations#manage'
  post '/evaluations' => 'evaluations#execute'
  resources :evaluations, only: %i[] do
    get 'download' => 'evaluations#download', param: :evaluation_id
  end
  resources :evaluations, only: %i[show], param: :evaluation_id

  namespace :api, format: 'json' do
    resources :analyses, only: [] do
      scope module: :analyses do
        resource :parameter, only: %i[show]
      end
    end
    resources :analyses, only: %i[show], param: :analysis_id
  end
end
