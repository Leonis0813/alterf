Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  get '/analyses' => 'analyses#index'
  post '/analyses' => 'analyses#execute'
  resources :analyses, only: %i[] do
    get 'download' => 'analyses#download', param: :analysis_id
    post 'rebuild' => 'analyses#rebuild', param: :analysis_id
  end
  resources :analyses, only: %i[show], param: :analysis_id

  get '/predictions' => 'predictions#manage'
  post '/predictions' => 'predictions#execute'

  get '/evaluations' => 'evaluations#manage'
  post '/evaluations' => 'evaluations#execute'
  resources :evaluations, only: %i[] do
    get 'download' => 'evaluations#download', param: :evaluation_id
    resources :races, only: %i[show], controller: 'evaluation/races', param: :race_id
  end
  resources :evaluations, only: %i[show], param: :evaluation_id

  namespace :api, format: 'json' do
    resources :analyses, only: [] do
      scope module: :analyses do
        resource :parameter, only: %i[show]

        resource :result, only: %i[] do
          scope module: :result do
            resources :importances, only: %i[index]
            resources :decision_trees, only: %i[show], param: :decision_tree_id
          end
        end
      end
    end
    resources :analyses, only: %i[show], param: :analysis_id
  end
end
