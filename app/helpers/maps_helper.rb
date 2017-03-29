module MapsHelper
  def is_secret_link?
    Map.find_by(secret_token: request[:map_token]).present?
  end

  def map_token
    request[:map_token]
  end
end
