Rails.application.routes.draw do
  get '/analyses' => 'analyses#manage'
  post '/analyses/learn' => 'analyses#learn'
end
