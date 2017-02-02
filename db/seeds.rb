require 'poi_repository'

# Destroy all DB elements first
User.destroy_all
Category.destroy_all
Announcement.destroy_all
Category.destroy_all
Place.destroy_all

# Seed users
User.create(id: 5000,
            name: 'admin',
            email: 'admin@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: true).save
User.create(id: 5001,
            name: 'user',
            email: 'user@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: false).save

# Seed real world data
# PoiRepository.import_from_csv('./db/initPois.csv', 'Berlin')

# Seed random data, see /lib/mass_seed_*.rb for definitions
MassSeedPoints.generate(number_of_points: 30, city: 'Berlin')
#MassSeedAnnouncements.generate(number_of_announcements: 10)
