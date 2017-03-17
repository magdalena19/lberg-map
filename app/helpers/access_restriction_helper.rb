module AccessRestrictionHelper
  def can_contribute?
    Admin::Setting.allow_guest_commits || @current_user.signed_in?
  end
end
