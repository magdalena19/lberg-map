class BingTranslatorWrapper
  attr_accessor :bing_translator

  def initialize(id, secret, account_key)
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

  def can_translate?(text)
    @bing_translator.balance >= text.length
  rescue
    false
  else
    true
  end

  def failsafe_translate(text, from, to)
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

module PlaceAutoTranslation
  def emptyish?(obj)
    obj.nil? || obj.empty?
  end

  def autotranslated_or_empty_descriptions
    translations.select { |t| t.auto_translated || emptyish?(t.description) }
  end

  def locales_of_empty_descriptions
    autotranslated_or_empty_descriptions.map(&:locale)
  end

  def translations_with_descriptions
    translations - autotranslated_or_empty_descriptions
  end

  def guess_native_language_description
    translations_with_descriptions.sort_by do |t|
      t.description.length
    end.last
  end

  def translate_empty_descriptions
    locales_of_empty_descriptions.each do |missing_locale|
      auto_translation = @translator.failsafe_translate(
        @native_translation.description,
        @native_translation.locale.to_s,
        missing_locale.to_s
      )
      translation = translations.find_by(locale: missing_locale)
      translation.without_versioning do
        translation.update_attributes(description: auto_translation,
                                      auto_translated: true,
                                      reviewed: false)
      end
    end
  end

  def auto_translate
    @native_translation = guess_native_language_description
    @translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
    translate_empty_descriptions if @translator && @native_translation
  end
end
