require 'mass_seed_announcements'
require 'mass_seed_points'

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

# See /lib/mass_seed_*.rb for definitions
MassSeedPoints.generate(number_of_points: 30, city: 'Berlin')
# MassSeedAnnouncements.generate(number_of_announcements: 400)
