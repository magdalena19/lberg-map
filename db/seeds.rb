# use high id's because auto-generated id's at form based creation begins with 1
Place.new( id: 1001,
              name: 'Seed Place',
              street: 'Magdalenenstr.',
              house_number: 22,
              postal_code: '10365',
              city: 'Berlin',
              latitude: 52.5,
              longitude: 13.5,
              description_en: 'English description...',
              description_de: 'Deutsche Beschreibung...',
              description_fr: 'Description francaise...',
              description_ar: 'وصف العربي',
            ).save(validate: false)

Place.new( id: 1002,
              name: 'Another random place',
              street: 'Methfesselstr.',
              house_number: 5,
              postal_code: '10965',
              city: 'Berlin',
              latitude: 52.55,
              longitude: 13.4,
              description_en: 'English description...',
              description_de: 'Deutsche Beschreibung...',
              description_fr: 'Description francaise...',
              description_ar: 'وصف العربي',
            ).save(validate: false)

Place.new( id: 1003,
              name: 'Haus vom Nikolaus',
              street: 'Platz der Republik',
              house_number: 1,
              postal_code: '11011',
              city: 'Berlin',
              latitude: 52.54,
              longitude: 13.3,
              description_en: 'English description...',
              description_de: 'Deutsche Beschreibung...',
              description_fr: 'Description francaise...',
              description_ar: 'وصف العربي',
            ).save(validate: false)

Category.create(id: 1,
                name_en: 'Playground',
                name_de: 'Spielplatz',
                name_fr: 'Spielplatz',
                name_ar: 'Spielplatz'
               )

Category.create(id: 2,
                name_en: 'Library',
                name_de: 'Bibliothek',
                name_fr: 'Bibliothek',
                name_ar: 'Bibliothek'
               )

Category.create(id: 3,
                name_en: 'Free Wlan',
                name_de: 'Kostenloses Wlan',
                name_fr: 'Kostenloses Wlan',
                name_ar: 'Kostenloses Wlan'
               )

Categorizing.create(category_id: 1, place_id: 1001)
Categorizing.create(category_id: 1, place_id: 1002)
Categorizing.create(category_id: 1, place_id: 1003)
Categorizing.create(category_id: 2, place_id: 1002)
Categorizing.create(category_id: 2, place_id: 1003)
Categorizing.create(category_id: 3, place_id: 1002)

# Users
User.create(id: 5000, name: "admin", email: "admin@test.com", password: "asdasd", password_confirmation: "asdasd", is_admin: false).save
User.create(id: 5001, name: "test", email: "test@test.com", password: "asdasd", password_confirmation: "asdasd", is_admin: true).save
