ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'posts', :action => 'index'
  # ==========================================================================
  # Frontend Resources
  # ==========================================================================
  map.page '/page/:action', :controller => "pages"
  map.resources :posts
  map.resources :pages
  map.connect ':year/:month/:day/:slug/comments/new', :controller => 'comments', :action => 'new'
  map.connect ':year/:month/:day/:slug/comments.:format', :controller => 'comments', :action => 'index'
  map.connect ':year/:month/:day/:slug', :controller => 'posts', :action => 'show', :requirements => { :year => /\d+/ }
  #map.posts_with_tag ':tag', :controller => 'posts', :action => 'index'
  #map.formatted_posts_with_tag ':tag.:format', :controller => 'posts', :action => 'index'


  # ==========================================================================
  # User Resources
  # ==========================================================================
  map.namespace :user do |user|
    user.resource  :account,                           :controller => 'account'
    user.resource  :password_reset
    user.resource  :session,                           :controller => 'session', :member => { :send_invitations => :post }
    user.logout    'session/end',                      :controller => 'session', :action => 'destroy'
    user.language  '/user_session/language/:language', :controller => 'session', :action => 'language'
    user.activate  '/activate/:activation_code',       :controller => 'account', :action => 'activate'
  end

  # ==========================================================================
  # Admin Resources
  # ==========================================================================
  map.namespace :admin do |admin|
    admin.root :controller => 'dashboard', :action => 'index'
    admin.resources :users,          :active_scaffold => true, :active_scaffold_sortable => true,
                                     :member          => { :suspend => :put,:unsuspend => :put, :activate => :put,:reset_password => :put },
                                     :collection      => { :pending => :get,:active => :get,:do_action => :get,:suspended => :get,:deleted => :get }
    admin.resources :groups,         :active_scaffold => true, :active_scaffold_sortable => true
    admin.resources :settings,       :active_scaffold => true, :active_scaffold_sortable => true
    admin.resources :announcements,  :active_scaffold => true, :active_scaffold_sortable => true
    admin.resources :commits,        :active_scaffold => true, :active_scaffold_sortable => true
    admin.resources :posts,          :active_scaffold => true, :active_scaffold_sortable => true,
                                     :has_many        =>  :comments,
                                     :new             =>  { :preview => :post },
                    :member     =>       { :check_delete => [:get, :post],
                                           :edit_tag => :get,
                                           :update_tag => :put }
    admin.resources :pages,          :active_scaffold => true, :active_scaffold_sortable => true,
                                     :new             =>  { :preview => :post }
    admin.resources :comments,       :active_scaffold => true, :active_scaffold_sortable => true,

                    :only       =>         :destroy,
                                     :member     =>    { :mark_as_spam => :put,
                                     :mark_as_ham => :put }
    admin.resources :tags,           :has_many => :posts
    admin.resources :action_entries, :active_scaffold => true, :active_scaffold_sortable => true,
                                     :member     =>    { :undo => :post }
  end
  
  # ==========================================================================
  # API Resources
  # ==========================================================================
  map.namespace :api do |api|
   api.resource :i18n
  end

  # ==========================================================================
  # Website Resources
  # ==========================================================================
  map.namespace :website do |website|
    website.root :controller => 'posts', :action => 'index'
	 website.resources :posts
  end

end
