module Helpers
  def login_as(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
  end

  def extract_attributes(obj)
    obj.attributes.except("id", "created_at", "updated_at")
  end
end
