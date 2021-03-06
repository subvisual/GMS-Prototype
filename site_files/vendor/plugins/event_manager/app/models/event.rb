class Event < ActiveRecord::Base
  # ==========================================================================
  # Relationships
  # ==========================================================================
  has_event_calendar :start_at_field  => 'starts_at', :end_at_field => 'ends_at'
  
  has_many   :events_users, :dependent => :destroy
  has_many   :users, :through => :events_users
  has_many   :event_activities, :dependent => :destroy
  belongs_to :post, :dependent => :destroy
  belongs_to :announcement, :dependent => :destroy
  belongs_to :global_category

                                                                       
  accepts_nested_attributes_for :post,         :allow_destroy => true 
  accepts_nested_attributes_for :announcement, :allow_destroy => true
  accepts_nested_attributes_for :event_activities, :allow_destroy => true 
  

  # ==========================================================================
  # Validations
  # ==========================================================================

  validates_presence_of :name, :starts_at, :ends_at, :price
  
  # ==========================================================================
  # Instance Methods
  # ==========================================================================

  #before_save :format_description
  #before_save :save_virtual_data
  after_save  :link_to_post_and_announcement

  attr_accessor :starts_at_natural
  attr_accessor :ends_at_natural
  
  def total_price(eventActivityUsers=[])
    sum = self.price
    eventActivityUsers.each do |eventActivityUser|
      sum += eventActivityUser.event_activity.price
    end  
    return sum
  end  
  
  def link_to_post_and_announcement
    if self.post
      new_post = self.post
      new_post.event = self
      new_post.save
    end  
    if self.announcement
      new_announcement = self.announcement
      new_announcement.event = self
      new_announcement.save
    end
  end  

  def create_excel_file(path)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => I18n::t('admin.events.manage.worksheet_title')
    sheet.row(0).concat [I18n::t('admin.events.manage.table.name'), I18n::t('admin.events.manage.table.email'), 
      I18n::t('admin.events.manage.table.nickname'),I18n::t('admin.events.manage.table.gender.title'), I18n::t('admin.events.manage.table.country'),
      I18n::t('admin.events.manage.table.phone'),I18n::t('admin.events.manage.table.address'),I18n::t('admin.events.manage.table.id_number')]
    
    self.users.each_index do |index|
      user = self.users[index]
      
      sheet.row(index+1).concat [user.name,user.email,user.nickname,
      (user.gender) ? I18n::t('admin.events.manage.table.gender.male') : I18n::t('admin.events.manage.table.gender.female'),
        user.country,user.phone,user.address,user.id_number]
    end  
    book.write path
  end  

  def format_description
    self.description_html = TextFormatter.format_as_xhtml(self.description)
  end

  def status(user_id)
    self.events_users.find_by_user_id(user_id).status
  end

  def confirm!(user_id)
    user_event = self.events_users.find_by_user_id(user_id)
    return user_event.confirm! if user_event
    false
  end

  def has_status?(user_id)
    user_events = self.events_users.find_by_user_id(user_id)
    return user_events.has_status? if user_events
    false
  end

  def undo_confirmation!(user_id)
    user_events = self.events_users.find_by_user_id(user_id)
    user_events.undo_confirmation!
  end

  def checked_activities(user_id)
    @list = []
    self.event_activities.each do |activity|
      @list << activity if activity.user_ids.include?(user_id)
    end
    return @list
  end

  def unchecked_activities(user_id)
    @list = []
    self.event_activities.each do |activity|
      @list << activity unless activity.user_ids.include?(user_id)
    end
    return @list
  end

  def remove_user_from_event(user_id)
    event_user = self.events_users.find_by_user_id(user_id)
    return event_user.destroy if event_user
    false
  end

  def user_lists
    list = []
    self.events_users.each do |event_user|
      list << { :event_user => event_user, :user => User.find(event_user.user_id) }
    end
    return list
  end

  def self.user_lists(events_users)
    list = []
    events_users.each do |event_user|
      list << { :event_user => event_user, :user => User.find(event_user.user_id) }
    end
    return list
  end

  def self.user_activities(events_users)
    result = Hash.new
    user_ids = []
    events_users.each do |user_event|
      user_ids << user_event.user_id
    end

    user_ids.each do |user_id|
      with_status = []
      default = []
      self.user_event_activities_list(user_id).each do |activity|
        user_activity = activity.event_activities_users.find_by_user_id(user_id)
        if user_activity.has_status?
          with_status << user_activity
        else
          default << user_activity
        end
      end
      result[user_id] = { :with_status => with_status, :default => default }
    end

    return result
  end

  def user_activities
    result = Hash.new
    user_ids = self.user_ids
    user_ids.each do |user_id|
      with_status = []
      default = []
      self.user_event_activities_list(user_id).each do |activity|
        user_activity = activity.event_activities_users.find_by_user_id(user_id)
        if user_activity.has_status?
          with_status << user_activity
        else
          default << user_activity
        end
      end
      result[user_id] = { :with_status => with_status, :default => default }
    end
    return result
  end

  def to_hash
    result = Hash.new
    result[:title] = self.title
    result[:description] = self.description
    #FIXME internacionalization
    result[:starts_at] = self.starts_at
    #FIXME internacionalization
    result[:ends_at] = self.ends_at
    withstatus = []
    default = []
    self.user_lists[:with_status].each do |user_list|
      withstatus << {:name => user_list[:user].name, :email => user_list[:user].email}
    end
    self.user_lists[:default].each do |user_list|
      default << {:name => user_list[:user].name, :email => user_list[:user].email}
    end
    result[:with_status] = withstatus
    result[:without_status] = default
    return result
  end

  def to_hash_with_activities
    result = self.to_hash
    temp = []
    self.event_activities.each do |activity|
      temp << activity.to_hash
    end
    result[:activities] = temp
    return result
  end

  def user_event_activities_list(user_id)
    user_activities = []
    activities = self.event_activities
    activities.each do |activity|
      user_activities << activity if activity.user_ids.include?(user_id)
    end
    return user_activities
  end

  def undo_confirmation?(user_id)
    self.event_activities.each do |activity|
      return false if activity.has_status?(user_id)
    end
    return true
  end

end
