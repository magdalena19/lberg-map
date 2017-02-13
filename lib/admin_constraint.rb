class AdminConstraint
  def matches?(request)
    binding.pry
    return false unless request.session[:user_id]
    user = User.find(request.session[:user_id])
    user && user.is_admin?
  end
end
