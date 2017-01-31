# This module holds all translation querying related class methods
module PlaceTranslationsClassMethods
  def all_translations
    Place.all.map { |p| p.translations.to_a }.flatten
  end

  def all_unreviewed_translations
    binding.pry
    Place.all_translations.select { |t| !t.reviewed }
  end
end

# This module holds all translation querying related class methods
module PlaceTranslations
  def self.included(base)
    base.extend PlaceTranslationsClassMethods
  end

  def unreviewed_translations
    translations.find_all do |t|
      t.versions.length > 1 || !t.reviewed
    end
  end

  def empty_description?
    translations.map { |t| t.description.nil? || t.description.empty? }.include? true
  end

  def set_description_reviewed_flags
    translations.each do |translation|
      translation.without_versioning do
        translation.update_attributes(reviewed: reviewed ? true : false)
      end
    end
  end

  def enqueue_auto_translation
    TranslationWorker.perform_async(id)
  end
end

