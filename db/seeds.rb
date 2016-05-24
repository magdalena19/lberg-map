# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Place.new(  name: 'Seed Place',
            street: 'Magdalenenstr.',
            house_number: 22,
            postal_code: '10365',
            city: 'Berlin',
            description_en: 'English description...',
            description_de: 'Deutsche Beschreibung...',
            description_fr: 'Description francaise...',
            description_ar: 'وصف العربي',
          ).save

Category.new( name_en: 'Playground', name_de: 'Spielplatz', name_fr: 'Spielplatz', name_ar: 'Spielplatz' ).save
Category.new( name_en: 'Library', name_de: 'Bibliothek', name_fr: 'Bibliothek', name_ar: 'Bibliothek' ).save
Category.new( name_en: 'Free Wlan', name_de: 'Kostenloses Wlan', name_fr: 'Kostenloses Wlan', name_ar: 'Kostenloses Wlan' ).save
