UserPosts::Application.routes.draw do

  controller :sessions do
    get 'login' => :new
    delete 'logout' => :destroy
    post 'login' => :create
  end

  resources :users, :only => [:new, :create, :index] do
    resources :posts, :except => [:edit, :update]
  end

  controller :posts do
    get 'posts' => :index_all
    get 'posts/more_posts' => :more_posts
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root :to => "posts#index_all"
end
