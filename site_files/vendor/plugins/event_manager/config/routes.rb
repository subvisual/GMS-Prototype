ActionController::Routing::Routes.draw do |map|

  # ==========================================================================
  # Admin Resources
  # ==========================================================================

  map.resources :events, :member => { :userUpdate => :post, :subscribe => :post, :unsubscribe => :get }
  map.resources :events do |events|
    events.resources :event_activities
  end

  map.namespace :admin do |admin|
    admin.resources :events,          :active_scaffold => true, :active_scaffold_sortable => true
    admin.resources :events,          :member =>  { :list_activities => :get }
    admin.resources :events do |event|
      event.resources :event_activities,      :active_scaffold => true, :active_scaffold_sortable => true
      event.resources :event_activities,      :member => { :delete => :get }
      event.resources :event_activity_manage, :collection => {  }
      event.resources :event_manage,          :member => { :index => :get  },
                                              :collection => { :download => :get }
    end
    
  end

  

end
