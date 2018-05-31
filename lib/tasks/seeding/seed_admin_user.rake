namespace :db do
  namespace :seed do
    desc 'mass_seed_points'
    task admin_user: :environment do
      email = ENV['APP_ADMIN_EMAIL']
      password = ENV['APP_ADMIN_PASSWD'] 

      User.create!(is_admin: true, name: 'App admin', email: email, password: password, password_confirmation: password)
    end
  end
end
