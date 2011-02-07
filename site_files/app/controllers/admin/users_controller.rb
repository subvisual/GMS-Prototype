class Admin::UsersController < Admin::BaseController
  filter_access_to :all, :require => any_as_privilege

  before_filter :load_groups, :only => :index

  active_scaffold :user do |config|
    config.subform.columns = [:email] 

    config.columns[:groups].show_blank_record = false

    config.columns[:role].form_ui = :select 
    config.columns[:groups].form_ui = :select 
    config.columns[:groups].options = {:draggable_lists => true}

    group_actions = Group.find_all_by_show_in_user_actions(true).map do |group|
      group = [ { :method => "add_to_group_#{group.id}", :name => group.name },
                { :method => "remove_from_group_#{group.id}", :name => group.name } ]
    end.flatten

    Scaffoldapp::active_scaffold config, "admin.users", 
      :list         => [ :created_at, :email, :active, :name, :role ], 
      :show         => [ :email, :active, :nickname, :profile, :website, :country, :gender ],
      :edit         => [ :email, :active, :nickname, :profile, :website, :country, :gender, :groups, :role ],
      :actions_list => [ :destroy_by_ids, :activate!, :deactivate! ].concat(group_actions)
  end

  # Override this method to define conditions to be used when querying a recordset (e.g. for List).
  # With this, only the users with the value 'false' in the column 'deleted' will be shown.
  def conditions_for_collection
    { :deleted => false }
  end

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

  # Active Scaffold hack
  # AS is not updating associated records (reason unknown)
  # 'do_edit' is executed in the beginning of the update routine
  # It finds the record from the DB before updating its fields
  # This way it is possible to update the associations before the 'save' in the end of the update method
  # This is necessary due to the user optional group picks validations
  def do_edit
    super
    unless params[:record].nil?
      if params[:record][:group_ids]
        # The next line is the only one needed from the IF sequence when the edit form uses formtastic
        @record.group_ids = params[:record][:group_ids]
      elsif params[:record][:groups]
        @record.group_ids = params[:record][:groups].map { |k,group| group[:id] }
      else
        @record.group_ids = []
      end
    end
  end

  protected

    def load_groups
      @groups = Group.all(:order => :name)
    end

end
