# Service object handling requests to external machine translation API
class AutoTranslationGateway
  attr_accessor :translator

  def initialize(id, secret, account_key)
    t = BingTranslator.new(id, secret, false, account_key)
    t.get_access_token
  rescue
    Rails.logger.error do
      "Encountered an error while trying to receive access
      token for BringTranslator instance. It's probable, that you supplied
      either an invalid 'id' or 'secret key' (or both)!"
    end
    @translator = nil
  else
    @translator = t
  end

  def can_translate?(text)
    @translator.balance >= text.length
  rescue
    false
  else
    true
  end

  def failsafe_translate(text:, from:, to:)
    if can_translate?(text)
      begin
        translation = @translator.translate(text, from: from.to_s, to: to.to_s)
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
