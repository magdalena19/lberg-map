# Wrapper for bing translation engine
class BingTranslatorWrapper
  attr_reader :bing_translator

  def initialize
    id = ENV['bing_id']
    secret = ENV['bing_secret']
    account_key = ENV['microsoft_account_key']

    @bing_translator = BingTranslator.new(id, secret, false, account_key)
  end

  def can_translate?(text)
    @bing_translator.get_access_token
  rescue
    false
  else
    true if @bing_translator.balance >= text.length
  end

  def translate(text:, from:, to:)
    if can_translate?(text)
      begin
        translation = @bing_translator.translate(text, from: from.to_s, to: to.to_s)
      rescue
        ''
      else
        translation
      end
    else
      ''
      # Maybe implement "keyswitching hack" later
    end
  end
end
