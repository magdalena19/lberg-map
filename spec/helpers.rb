module Helpers
  def login_as(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_ud] = nil
  end
end
