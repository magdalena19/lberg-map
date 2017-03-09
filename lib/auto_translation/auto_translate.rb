require 'auto_translation/auto_translation_gateway'
require 'auto_translation/translation_engines/null_translator'

# Module containing methods extending objects with auto-translation capabilities
module AutoTranslate
  def auto_translate_empty_attributes
    @translator = AutoTranslationGateway.new
    translated_attributes.each do |attribute, _value|
      @attribute = attribute
      @native_translation = guess_native_language
      translate_and_update if @native_translation
    end
  end

  private

  def receive_translation(text:, from:, to:)
    @translator.translate(text: text,
                          from: from,
                          to: to)
  end

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

  def translate_and_update
    missing_locales.each do |missing_locale|
      auto_translation = receive_translation(text: @native_translation.send("#{@attribute}"),
                                             from: @native_translation.locale,
                                             to: missing_locale)
      translation_record = translations.find_by(locale: missing_locale)
      update = -> { translation_record.send "update_attributes", { "#{@attribute}": auto_translation, auto_translated: true } }
      if self.respond_to? :versions
        translation_record.without_versioning { update.call }
      else
        update.call
      end
    end
  end
end
