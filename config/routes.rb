Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses' => 'analyses#execute'

  get '/predictions' => 'predictions#manage'
  post '/predictions' => 'predictions#execute'

  get '/evaluations' => 'evaluations#manage'
  post '/evaluations' => 'evaluations#execute'
end
