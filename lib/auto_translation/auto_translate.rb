require 'auto_translation/translation_engines/bing_translator_wrapper'
require 'auto_translation/translation_engines/yandex_translator_wrapper'
require 'auto_translation/translation_engines/google_translator_wrapper'
require 'auto_translation/translation_engines/null_translator'

# Module containing methods extending objects with auto-translation capabilities
module AutoTranslate
  def auto_translate_empty_attributes
    @translator = active_translation_engine
    translated_attributes.each do |attr, _value|
      @attribute = attr
      @native_translation = guess_native_language
      translate_and_update if @native_translation
    end
  end

  private

  def active_translation_engine
    engine = Admin::Setting.translation_engine
    engine_wrapper = "#{engine.camelize}TranslatorWrapper".singularize.constantize
  rescue
    NullTranslator.new
  else
    engine_wrapper.new
  end

  def translate(text:, from:, to:)
    return '' unless can_translate?(text: text, languages: [from, to])
    translation = @translator.translate(text: text,
                                        from: from,
                                        to: to)
  rescue
    ''
  else
    translation
  end

  private

  def can_translate?(text:, languages:)
    @translator.char_balance_sufficient?(text: text) &&
      @translator.languages_available?(lang_codes: languages) &&
      text.present?
  end

  def autotranslated_or_empty
    translations.select { |t| !t[@attribute].present? || t.auto_translated }
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
      auto_translation = translate(text: @native_translation.send("#{@attribute}"),
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
