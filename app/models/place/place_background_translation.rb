module PlaceBackgroundTranslation
  def enqueue_auto_translation
    TranslationWorker.perform_async('Place', id, map.supported_languages)
  end
end
