module PlaceBackgroundTranslation
  def enqueue_auto_translation
    TranslationWorker.perform_async('Place', id) if Admin::Setting.auto_translate
  end
end
