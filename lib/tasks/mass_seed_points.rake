require 'mass_seed_points'

desc 'mass_seed_points'
task mass_seed_points: :environment do
  ARGV.each { |a| task a.to_sym do ; end }
  MassSeedPoints.generate(number_of_points: ARGV[1].to_i, city: ARGV[2])
end
