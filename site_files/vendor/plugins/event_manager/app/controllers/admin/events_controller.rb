class Admin::EventsController < Admin::BaseController

  before_filter :date_localization, :only => [ :create, :update ]

  active_scaffold :event do |config|
    Scaffoldapp::active_scaffold config, "admin.events",
      :create => [ :title, :description, :starts_at, :ends_at, :price, :participation_message ],
      :edit   => [ :title, :description, :starts_at, :ends_at, :price, :participation_message ],
      :list   => [ :title, :starts_at, :ends_at, :price ],
      :show   => [ ]

#    config.action_links.add 'index', :type => :member, :page => true, :method => :get,
 #                                    :label => I18n::t("admin.events.index.manage_link"),
  #                                   :controller => 'admin/event_manage'
  end

=begin
  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.update_attributes(params[:event])
    @event.save!
    redirect_to admin_event_path(@event.id)
  end

  def create
    @event = Event.new
    @event.attributes = params[:event]
    @event.save!
    redirect_to admin_event_path(@event.id)
  end

  def index
    @events = Event.all
  end
=end

  def show
    redirect_to :action => 'index', :controller => 'admin/event_manage', :event_id => params[:id]
    #refreshContent
  end

  def refreshContent
    @record = Event.find(params[:id])
    @checked_activities = @record.checked_activities(current_user.id)
    @unchecked_activities = @record.unchecked_activities(current_user.id)
  end
 
  def userUpdate

    eventid = params[:id]
    to_delete = params[:idsu].split(',')
    to_create = params[:idsc].split(',')

    to_delete.each do |activity_id|
      activity = EventActivitiesUser.find_by_event_activity_id_and_user_id(activity_id,current_user.id)
      activity.destroy if activity
    end

    to_create.each do |activity_id|
      activity = EventActivitiesUser.new(:event_activity_id => activity_id, :user_id => current_user.id)
      activity.save!
    end

    if (params[:joinEvent] == 'true')
      evento = Event.find(eventid)
      evento.users << current_user
      evento.save!
    elsif (params[:joinEvent] == 'false')
      evento = Event.find(eventid)
      user_event = evento.events_users.find_by_user_id(current_user.id)
      user_event.destroy if user_event
    end

    refreshContent

    event_user = EventsUser.find_by_event_id_and_user_id(eventid,current_user.id)
    if event_user
      respond_to do |format|
        format.json { render :json => {
              'id'   => eventid,
              'html' => '<h2>' +
                  event_user.event.participation_message.to_s + 
                  '</h2> <br> <br> ' + 
                  t("admin.events.view.totalprice") + 
                  ': ' + event_user.total_price.to_s + ' <br> <br> ' +
                  '<a href="" onclick="windows.location.href=\"\"" class="cancel">' + t("admin.events.view.cancel") + '</a>'
          }
        }
       end
    else   
      respond_to do |format|
        format.json { render :json => { 'id' => false } }
      end
    end

  end

  protected

    def date_localization
      begin
        [:starts_at, :ends_at].each do |attribute|
          params[:record][attribute] = DateTime.strptime(params[:record][attribute], "%d/%m/%Y %H:%M").to_time
        end
      rescue ArgumentError
        flash[:error] = t("flash.invalid_date")
        redirect_to :action => params[:action] == 'create' ? 'new' : 'edit'
        return
      end
    end

end
