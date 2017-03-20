# Wrapper for google translation engine
class GoogleTranslatorWrapper
  def translate(translation_request:)
    translation = EasyTranslate.translate(text: translation_request.text,
                                          from: translation_request.from.to_s,
                                          to: translation_request.to.to_s,
                                          api_key: ENV['google_translate_secret'] )
  end

  def languages_available?(translation_request:)
    language_pairs_available = EasyTranslate.translations_available
    matches = [translation_request.from, translation_request.to].each do |language|
      languages_available.include?(language)
    end
  rescue
    false
  else
    matches.any?
  end
end
