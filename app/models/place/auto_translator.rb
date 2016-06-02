module Place::AutoTranslator
  class BingTranslatorWrapper < BingTranslator
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

    def failsafe_translate(text, from, to)
      if @bing_translator.balance >= text.length
        begin
          translation = @bing_translator.translate(text, from: from, to: to)
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
end
