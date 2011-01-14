# Defines
Factory.define :user do |u|
  u.name     'Joh Doe'
  u.password 'SuperPass'
  u.password_confirmation { |u| u.password }
  u.email {|a| "#{a.first_name}@example.com".downcase }
end

Factory.define :post do |p|
  p.title     'Great Post'
  p.body 'Lorem'
  p.published_at 'now'  
end

class Factory
  def self.give_me_an_active_user(hash=nil)
    u=Factory(:user, hash)
    u.activate!
    return u
  end
  def self.give_me_an_admin_user(hash=nil)
    u=Factory(:user, hash)
    u.role_id = 1
    u.activate!
    return u
  end
  def self.give_me_a_post(hash=nil)
    p=Factory(:post, hash)
    return p
  end 
end
