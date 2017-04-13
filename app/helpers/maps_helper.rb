module MapsHelper
  def is_secret_link?
    Map.find_by(secret_token: request[:map_token]).present?
  end

  def any_maps_available?
    @current_user.registered? || session[:maps].any? 
  end

  def can_review?
    current_map.allow_guest_commits && (current_map.owner == @current_user || is_secret_link?)
  end

  def map_token
    request[:map_token]
  end

  def map_panel_header_class(map:)
    if not map.is_public?
      'private_map'
    elsif map.is_restricted?
      'restricted_access_map'
    else
      'public_map'
    end
  end
end
