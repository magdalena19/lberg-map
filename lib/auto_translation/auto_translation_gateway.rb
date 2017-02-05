# Service object handling requests to external machine translation APIs
class AutoTranslator
  attr_accessor :translator

  def initialize(engine)
    engine_wrapper = "#{engine.camelize}Wrapper".singularize.constantize
    @translator = engine_wrapper.new || NullTranslator.new
  end

  def can_translate?(text)
    @translator.can_translate?(text)
  end

  def translate(text:, from:, to:)
    @translator.translate(text: text, from: from, to: to)
  end
end
