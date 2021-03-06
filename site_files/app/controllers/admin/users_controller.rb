class Admin::UsersController < Admin::BaseController
  filter_access_to :all, :require => any_as_privilege

  before_filter :load_groups, :only => :index

  active_scaffold :user do |config|
    
    group_actions = Group.find_all_by_show_in_user_actions(true).map do |group|
      group = [ { :method => "add_to_group_#{group.id}", :name => group.name },
                { :method => "remove_from_group_#{group.id}", :name => group.name } ]
    end.flatten 
 
    Scaffoldapp::active_scaffold config, "admin.users", 
      :list         => [ :created_at, :email, :active, :name, :role ], 
      :show         => [ :email, :active, :nickname, :profile, :website, :country, :gender ],
      :edit         => [ :email, :active, :nickname, :profile, :website, :country, :gender, :group_ids, :role_id, :avatar, 
                         :phone, :role, :name, :address, :id_number ],
      :actions_list => [ :delete_by_ids!, :activate!, :deactivate! ].concat(group_actions)
  end

  # Override this method to define conditions to be used when querying a recordset (e.g. for List).
  # With this, only the users with the value 'false' in the column 'deleted' will be shown.
#  def conditions_for_collection
#    return { :deleted => false }
#  end

  def custom_finder_options
    return { :joins => 'INNER JOIN groups_users ON users.id = groups_users.user_id',
             :conditions => { 'groups_users.group_id' => params[:group] }
           } if params[:group]
    return { }
  end

  def do_destroy
    @record = find_if_allowed(params[:id], 'delete')
    if request.method == :delete
      begin
        self.successful = @record.delete!
      rescue
        flash[:warning] = as_(:cant_destroy_record, user.to_label)
        self.successful = false
      end
    end
  end

  # Overrided this action to show revertion previews and revert option
  def show
    if params[:history_entry_id]
      @actual_record = User.find params[:id] 
      @history_entry = HistoryEntry.find(params[:history_entry_id])
      @record        = @history_entry.historicable_preview
    else
     super   
    end
  end
  
  protected

    def load_groups
      @groups = Group.all(:order => :name)
    end
  
end
