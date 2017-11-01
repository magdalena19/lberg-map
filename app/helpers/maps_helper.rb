module MapsHelper
  def is_secret_link?
    Map.find_by(secret_token: request[:map_token]).present?
  end

  def any_maps_available?
    @current_user.registered? || session[:maps].any? 
  end

  # Check if is accessed via map secret link or current user is owner
  def has_privileged_map_access?(map: nil)
    map_in_scope = map || current_map
    map_in_scope&.owned_by?(user: @current_user) || is_secret_link?
  end

  def can_review?
    current_map.allow_guest_commits && has_privileged_map_access?
  end

  def map_token
    request[:map_token]
  end

  def map_access_level(map:)
    if not map.is_public?
      'private-map'
    else
      'public-map'
    end
  end
end
