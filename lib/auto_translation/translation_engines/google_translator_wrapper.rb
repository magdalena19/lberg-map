# Wrapper for google translation engine
class GoogleTranslatorWrapper
  def can_translate?(text)
    EasyTranslate.translations_available
  rescue
    false
  else
    true
  end

  def translate(text:, from:, to:)
    if can_translate?(text)
      begin
        translation = EasyTranslate.translate(text, from: from.to_s, to: to.to_s, api_key: ENV['google_translate_secret'] )
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
