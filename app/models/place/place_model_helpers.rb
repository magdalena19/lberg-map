module PlaceModelHelpers
  def enforce_ssl_on_urls
    homepage.gsub!('www.', '')
    # Returns nil if no valid protocol prefix found!
    domain = URI.parse(homepage).host
    if domain
      self.homepage = 'https://' + domain
    else
      self.homepage = 'https://' + homepage
    end
  end
end
