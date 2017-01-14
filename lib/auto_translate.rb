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

  def failsafe_translate(text:, from:, to:)
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

module AutoTranslate
  def auto_translate_empty_attributes
    init_translator if Rails.env != 'test'

    translated_attributes.each do |attribute, _value|
      set_translation_scope attribute: attribute
      @native_translation = guess_native_language
      translate_attribute if @native_translation
    end
  end

  private

  def set_translation_scope(attribute:)
    @attribute = attribute
  end

  def init_translator
    @translator = BingTranslatorWrapper.new(ENV['bing_id'], ENV['bing_secret'], ENV['microsoft_account_key'])
  end

  # Only 'empty' relevant in the current context?
  def autotranslated_or_empty
    translations.select { |t| t.auto_translated || !t[@attribute].present? }
  end

  def missing_locales
    autotranslated_or_empty.map(&:locale)
  end

  def translations_with_content
    translations - autotranslated_or_empty
  end

  def guess_native_language
    translations_with_content.sort_by do |t|
      t[@attribute].length
    end.last
  end

  def translate_attribute
    missing_locales.each do |missing_locale|
      if Rails.env == 'test'
        auto_translation = 'auto_translation: test_stub'
      else
        return nil unless @translator && @native_translation
        auto_translation = @translator.failsafe_translate(text: @native_translation[@attribute],
                                                          from: @native_translation.locale,
                                                          to: missing_locale)
      end
      translation = translations.find_by(locale: missing_locale)
      translation.without_versioning do
        translation.send "update_attributes", { "#{@attribute}": auto_translation, auto_translated: true }
      end
    end
  end
end
