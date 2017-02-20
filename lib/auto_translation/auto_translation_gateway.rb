# Service object handling requests to external machine translation APIs
class AutoTranslationGateway
  attr_accessor :translator

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

  def can_translate?(text)
    @engine.can_translate?(text)
  end

  def translate(text:, from:, to:)
    @engine.translate(text: text, from: from, to: to)
  end
end
