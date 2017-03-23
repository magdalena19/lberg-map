# This module holds all translation reviewing related class methods
module PlaceTranslationsAuditing
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
      translation.update_attributes(reviewed: reviewed ? true : false)
    end
  end
end

