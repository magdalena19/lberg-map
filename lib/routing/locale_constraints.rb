class LocaleConstraints
  def requested_map(token:)
    return nil if token.nil?
    Map.find_by(secret_token: token) || Map.find_by(public_token: token)
  end

  def matches?(request)
    map = requested_map(token: request[:map_token])
    requested_locale = request[:locale]
    supported_languages = map ? map.supported_languages : I18n.available_locales.map(&:to_s)
    unless supported_languages.include? requested_locale
      redirect_locale = supported_languages.first 
      request[:locale] = redirect_locale
    end
    return true
  end
end
