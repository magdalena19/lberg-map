# Wrapper for bing translation engine
class BingTranslatorWrapper
  def initialize
    @translator= BingTranslator.new(ENV['bing_secret'])
  end

  def translate(translation_request:)
    @translator.translate(text: translation_request.text,
                          from: translation_request.from.to_s,
                          to: translation_request.to.to_s)
  end

  def languages_available?(translation_request:)
    languages_available = @translator.supported_language_codes
    matches = [translation_request.from, translation_request.to].each do |language|
      languages_available.include?(language)
    end
  rescue
    false
  else
    matches.all?
  end

  # Method for reflecting availability of translation engine
  # TODO Can query API directly?
  def self.working?
    ENV['bing_secret'].present?
  end
end
