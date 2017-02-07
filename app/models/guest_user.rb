class GuestUser
  def name
    I18n.t('activerecord.attributes.guest_user.name')
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
    false
  end
end
