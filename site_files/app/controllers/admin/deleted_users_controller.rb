class Admin::DeletedUsersController < Admin::BaseController
#  filter_access_to :all, :require => any_as_privilege #FIXME: uncomment this line

  active_scaffold :user do |config|
    config.subform.columns = [:email]

    config.columns[:groups].show_blank_record = false
    config.nested.add_link("<img src='/images/icons/book_open.png'/>History", [:history_entries])


    config.columns[:role].form_ui = :select 
    config.columns[:groups].form_ui = :select 
    config.columns[:groups].options = {:draggable_lists => true}
  
    Scaffoldapp::active_scaffold config, "admin.users", 
      :list         => [ :created_at, :email, :active, :name, :role ], 
      :show         => [ :email, :active, :nickname, :profile, :website, :country, :gender ],
      :edit         => [ :email, :active, :nickname, :profile, :website, :country, :gender, :groups, :role ],
      :actions_list => [ :destroy_by_ids, :activate!, :deactivate! ]
  end

  # Override this method to define conditions to be used when querying a recordset (e.g. for List).
  # With this, only the users with the value 'false' in the column 'deleted' will be shown.
  def conditions_for_collection
    return { :deleted => true }
  end
  
  # Method that receives all requests and calls the desired action with the selected ids,
  # and returns the re-rendered html
  def do_action
    if !params[:ids].nil?
      ids = params[:ids].split('&')
    else ids = [ params[:id] ]
    end
    if User.send(params[:actions],ids)  
      list
    else
      render :text => "" 
    end      
  end
  
end