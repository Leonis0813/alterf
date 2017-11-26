Rails.application.routes.draw do
  get '/analysis' => 'analysis#manage'
  post '/analysis/learn' => 'analysis#learn'
end
