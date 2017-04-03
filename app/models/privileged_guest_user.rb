class PrivilegedGuestUser
  def name
    I18n.t('activerecord.attributes.privileged_user.name')
  end

  def email
    ""
  end

  def guest?
    true
  end

  def admin?
    false
  end

  def signed_in?
    true
  end

  def registered?
    false
  end
end
