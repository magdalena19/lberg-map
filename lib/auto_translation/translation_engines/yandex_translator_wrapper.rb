# Wrapper for yandex translation engine
class YandexTranslatorWrapper
  def initialize
    @translator = Yandex::Translator.new ENV['yandex_secret']
  end

  def translate(translation_request:)
    @translator.translate(text: translation_request.text,
                          from: translation_request.from.to_s,
                          to: translation_request.to.to_s)
  end

  def languages_available?(translation_request:)
    language_pairs_available = @translator.langs
    matches = language_pairs_available.map do |pair|
      pair == "#{translation_request.from}-#{translation_request.to}"
    end
  rescue
    false
  else
    matches.any?
  end
end
