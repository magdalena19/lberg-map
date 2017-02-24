# Wrapper for yandex translation engine
class YandexTranslatorWrapper
  attr_reader :yandex_translator

  def initialize
    id = ENV['yandex_secret']
    @yandex_translator = Yandex::Translator.new(id)
  end

  def translate(text:, from:, to:)
    translation = @yandex_translator.translate(text, from: from.to_s, to: to.to_s)
  end

  def char_balance_sufficient?
    # TODO implement that
    false
  end

  def languages_available?(lang_codes)
    languages_available = @yandex_translator.langs
    matches = lang_codes.each do |language|
      languages_available.include?(language)
    end
  rescue
    false
  else
    matches.all?
  end
end
