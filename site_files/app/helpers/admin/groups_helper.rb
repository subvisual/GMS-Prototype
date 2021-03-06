module Admin::GroupsHelper

  #Method to generate tree as lists
  def generate_tree(group) 
    out = group[0] || "<h4>"+I18n.t("admin.groups.index.sidebar.hierarchy.subname")+"</h4>"
    if group.size > 1
      out += "<ul class=\"inner\">"
      group[1..-1].each do |subgroup|
        out += "<li>" + generate_tree(subgroup) + "</li>"
      end
      out += "</ul>"
    end
 
    return out
  end
  
  #
  def groups_names
    users = {}
    users_groups.each do |k,v|
      v.each do |group|
        if users[k]
          users[k] += ", #{group.name}"
        else
          users[k]  = users_hash[k].name + " (" + group.name  
        end
      end
    end
    
    users
  end

  #Redefining layout for manageable by root only field
  #FIXME: the label still appears
  #def manageable_by_root_only_form_column(record, input_name)
  #  #check_box :record, :manageable_by_root_only, :name => input_name
  #  nil
  #end

  #How to remove users for groups
  #FIXME: the label still appears
  #def users_form_column(record, input_name)
  #  #check_box :record, :manageable_by_root_only, :name => input_name
  #  nil
  #end
  
end
