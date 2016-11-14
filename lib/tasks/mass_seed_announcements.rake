require 'mass_seed_announcements'

desc 'mass_seed_announcements'
task mass_seed_announcements: :environment do
  ARGV.each { |a| task a.to_sym do ; end }
  MassSeedAnnouncements.generate(number_of_announcements: ARGV[1].to_i)
end
