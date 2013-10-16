WebsiteDifference::Application.routes.draw do
  root to: "sites#index"
  resources :sites do
  	put '/update_time' => 'sites#update_time', on: :member
  end
end
