# To be included in Place class
module Twitter
  attr_accessor :client, :tweet

  def tweet_place
    init_client

    begin
      client.update(tweet) if map.autopost_twitter
    rescue => e
      e
    end
  end

  private

  def tweet
    @tweet = "#{map.twitter_autopost_message}: #{name} #{map.twitter_hashtags}"
  end

  def init_client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = map.twitter_api_key
      config.consumer_secret     = map.twitter_api_secret_key
      config.access_token        = map.twitter_access_token
      config.access_token_secret = map.twitter_access_token_secret
    end
  end
end
