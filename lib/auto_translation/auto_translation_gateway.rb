# Service object handling requests to external machine translation APIs
class AutoTranslationGateway
  attr_reader :engine

  def initialize
    engine = Admin::Setting.translation_engine
    engine_wrapper = "#{engine.camelize}TranslatorWrapper".singularize.constantize
  rescue
    @engine = NullTranslator.new
  else
    @engine = engine_wrapper.new
  end

  def engine
    @engine.class
  end

  def translate(text:, from:, to:)
    return '' unless can_translate?(text: text, languages: [from, to])
    translation = @engine.translate(text: text, from: from.to_s, to: to.to_s)
  rescue
    ''
  else
    translation
  end

  private

  def can_translate?(text:, languages:)
    @engine.char_balance_sufficient?(text) &&
      @engine.languages_available?(languages) &&
      text.present?
  end
end
