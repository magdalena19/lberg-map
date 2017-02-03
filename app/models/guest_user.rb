class GuestUser
  def name
    "Guest"
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
