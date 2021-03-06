class ToDo < ActiveRecord::Base
  # ==========================================================================
  # Relationships
  # ==========================================================================
  acts_as_list :scope => :to_do_list
  belongs_to :to_do_list
  belongs_to :user
  has_many :comments, :class_name => "ToDoComment", :dependent => :destroy

  # ==========================================================================
  # Validations
  # ==========================================================================

   validates_presence_of :description

  # ==========================================================================
  # Extra defnitions
  # ==========================================================================

  named_scope :ordered_finished, lambda{ |id| {:conditions => { :to_do_list_id => id } , :order => "finished_date desc"}}
  named_scope :ordered_position_done, lambda{ |id| {:conditions => { :to_do_list_id => id, :done => false }, :order => "position asc"}}

  # ==========================================================================
  # Instance Methods
  # ==========================================================================



  # ==========================================================================
  # Class Methods
  # ==========================================================================

  class << self
    
  end
  
end
