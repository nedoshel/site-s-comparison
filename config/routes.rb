WebsiteDifference::Application.routes.draw do
  root to: "sites#index"
  resources :sites do
  	get '/update_time' => 'sites#update_time', on: :member
  end
end
