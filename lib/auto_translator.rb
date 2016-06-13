class BingTranslatorWrapper
  attr_accessor :bing_translator

  def initialize(id, secret, account_key)
    begin
      t = BingTranslator.new(id, secret, false, account_key)
      t.get_access_token
    rescue
      Rails.logger.error do
        "Encountered an error while trying to receive access
        token for BringTranslator instance. It's probable, that you supplied
        either an invalid 'id' or 'secret key' (or both)!"
      end
      @bing_translator = nil
    else
      @bing_translator = t
    end
  end

  def can_translate?(text)
    # debugger
    begin
      @bing_translator.balance >= text.length
    rescue
      false
    else
      true
    end
  end

  def failsafe_translate(text, from, to)
    # debugger
    if can_translate?(text)
      begin
        translation = @bing_translator.translate(text, from: from, to: to)
      rescue
        ''
      else
        prefix = I18n.send('translate', "auto_translation_prefix_#{to}")
        "#{prefix} #{translation}"
      end
    else
      ''
      # Maybe implement "keyswitching hack" later
    end
  end
end
