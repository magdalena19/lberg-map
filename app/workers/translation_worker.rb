class TranslationWorker
  include Sidekiq::Worker

  def perform(place_id)
    place = Place.find(place_id)
    place.auto_translate
  end
end
