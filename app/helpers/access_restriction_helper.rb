module AccessRestrictionHelper
  attr_reader :token
  
  def is_secret_link?
    Map.find_by(secret_token: token)
  end

  def can_commit_as_guest?
    map = Map.find_by(public_token: token)
    map && map.is_public && map.allow_guest_commits
  end

  def can_contribute?
    @token = request[:map_token]
    return true if is_secret_link? || can_commit_as_guest?
    false
  end
end
