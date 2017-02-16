# Wrapper for yandex translation engine
class YandexTranslatorWrapper
  attr_reader :yandex_translator

  def initialize
    id = ENV['yandex_secret']

    @yandex_translator = Yandex::Translator.new(id)
  end

  def can_translate?(text)
    @yandex_translator.langs
  rescue
    false
  else
    # true if @yandex_translator.balance >= text.length
    true
  end

  def translate(text:, from:, to:)
    if can_translate?(text)
      begin
        translation = @yandex_translator.translate(text, from: from.to_s, to: to.to_s)
      rescue
        ''
      else
        translation
      end
    else
      ''
    end
  end
end
