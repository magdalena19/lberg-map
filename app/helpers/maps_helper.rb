module MapsHelper
  def is_secret_link?
    Map.find_by(secret_token: request[:map_token]).present?
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
