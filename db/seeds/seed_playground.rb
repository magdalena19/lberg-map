require 'poi_repository'

# Destroy all DB elements first
User.destroy_all
Category.destroy_all
Category.destroy_all
Place.destroy_all
Map.destroy_all

# Seed users
User.create(name: 'admin',
            email: 'admin@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: true).save
User.create(name: 'user',
            email: 'user@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: false).save

# Seed random data, see /lib/mass_seed_*.rb for definitions
MassSeedPoints.generate(number_of_points: 30, city: 'Berlin')
