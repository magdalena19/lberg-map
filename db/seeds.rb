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
            categories_list: 'foo, bar',
            description_en: 'English description...',
            description_de: 'Deutsche Beschreibung...',
            description_fr: 'Description francaise...',
            description_ar: 'وصف العربي',
            ).save
