require 'fork_locale_file'

desc 'Recursively traverse through your locale file tree and fork every file from existing localisations to provide the basic structure for new languages to support in your application (params: from, to)'
task fork_locale_file: :environment do
  ARGV.each { |a| task a.to_sym do ; end }
  to = ARGV[2].split(',')
  ForkLocaleFile.fork(from: ARGV[1], to: to)
end
