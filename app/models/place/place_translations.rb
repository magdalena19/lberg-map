# This module holds all translation querying related class methods
module PlaceTranslationsClassMethods
  def all_translations
    Place.all.map(&:translations)
  end

  def all_unreviewed_translations
    array = []
    Place.all.each do |p|
      array << p.unreviewed_translations
    end
    array.flatten!
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

end

