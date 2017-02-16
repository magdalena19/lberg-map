# Module containing methods used for auto-translating object attributes
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
    # TODO pass engine name here, take from settings
    @translator = AutoTranslationGateway.new
  end

  # Useful for participation feature
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
        auto_translation = @translator.translate(text: @native_translation[@attribute],
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
