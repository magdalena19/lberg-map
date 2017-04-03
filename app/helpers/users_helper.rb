module UsersHelper
  def needs_activation_token?
    !@current_user.admin? && params[:action] == 'sign_up'
  end
end
