# Wrapper for google translation engine
class GoogleTranslatorWrapper
  def translate(text:, from:, to:)
    translation = EasyTranslate.translate(text, from: from.to_s, to: to.to_s, api_key: ENV['google_translate_secret'] )
  end

  def languages_available?(lang_codes)
    languages_available = EasyTranslate.translations_available
    matches = lang_codes.each do |language|
      languages_available.include?(language)
    end
  rescue
    false
  else
    matches.all?
  end

  def char_balance_sufficient?
    # TODO implement that!
    false
  end
end
