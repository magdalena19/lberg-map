require 'auto_translation/translation_engines/bing_translator_wrapper'
require 'auto_translation/translation_engines/yandex_translator_wrapper'
require 'auto_translation/translation_engines/google_translator_wrapper'
require 'auto_translation/translation_engines/null_translator'

# Module containing methods extending objects with auto-translation capabilities
module AutoTranslate

  module Helpers
    # Translation system status
    def self.translation_engine_working?(engine:)
      engine_wrapper = "#{engine.camelize}TranslatorWrapper".singularize.constantize
      engine_wrapper.working?
    end
  end

  class TranslationRequest
    attr_reader :text, :from, :to

    def initialize(text:, from:, to:)
      @text = text
      @from = from
      @to = to
    end
  end

  def auto_translate_empty_attributes(supported_languages: I18n.available_locales)
    @translator = active_translation_engine
    @languages_set = supported_languages.map(&:to_s)
    translated_attributes.each do |attr, _value|
      @attribute = attr
      @native_translation = guess_native_language
      translate_and_update if @native_translation
    end
  end

  private

  def active_translation_engine
    engine = Map.find(map_id).translation_engine
    engine_wrapper = "#{engine.camelize}TranslatorWrapper".singularize.constantize
  rescue
    NullTranslator.new
  else
    engine_wrapper.new
  end

  def translate(translation_request:)
    translation =
      if text.present? && @translator.languages_available?(translation_request)
        @translator.translate(translation_request)
      else
        ''
      end
  rescue Exception => e
    Rails.logger.error e.message
    ''
  else
    translation
  end

  # crucial
  def autotranslated_or_empty
    translations.
      select { |t| @languages_set.include? t.locale.to_s }.
      select { |t| !t[@attribute].present? || t.auto_translated }
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
      request = TranslationRequest.new(text: @native_translation.send("#{@attribute}"),
                                       from: @native_translation.locale,
                                       to: missing_locale)
      auto_translation = translate(translation_request: @request)
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
