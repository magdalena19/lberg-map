module Admin::SettingsHelper
  def is_boolean(obj)
    [true, false].include? obj
  end

  def is_string(obj)
    obj.class == String
  end

  def is_collection(obj)
    obj.class == Array
    
  end
end
