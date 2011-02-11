class Admin::ProjectsController < Admin::BaseController
  filter_access_to :all,           :require => any_as_privilege
  filter_access_to :create, :new, :require => :create

  active_scaffold :project do |config|

    config.columns[:groups].form_ui = :select
    config.columns[:groups].options = {:draggabledd_lists => true}

    Scaffoldapp::active_scaffold config, "admin.project",
      :list     => [ :name, :description ],
      :show     => [ ],
      :create   => [ :name, :description, :users ],
      :edit     => [ :name, :description, :users ]
  end

  def do_list
    require 'ostruct'
    @records = Project.find_all_for_user current_user
    @page = OpenStruct.new :items => @records, :number => @records.size, :pager => OpenStruct.new({ :infinite? => false, :count => @records.size, :number_of_pages => @records.size/15})
  end

  def show
    @project = Project.find(params[:id])
    redirect_to admin_project_to_do_lists_path(@project)
  end

  def create
    project = Project.new params[:project]
    project.user = current_user
    if project.save
      flash[:notice] = t("flash.project_created")
    else
      flash[:error] = t("flash.project_creation_fail")
    end    
    
    redirect_to admin_projects_path
  end

  def new
    @project = Project.new
    @users = User.all

    render :new
  end

end
