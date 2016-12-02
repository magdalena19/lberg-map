class Rack::Attack
  throttle('req/ip', :limit => 100, :period => 30.second) do |req|
    req.ip
  end

  # limit login to 3 attempts (2 params passed) in 60 seconds
  throttle('logins/email', :limit => 6, :period => 60.seconds) do |req|
    req.params['sessions'] if req.path.ends_with?('/login') && req.post?
  end

  self.throttled_response = lambda do |env|
    [ 429,  # status
      {},   # headers
      ['Too many requests. Please try again later...'] # body
    ]
  end

end
