# set path to application
app_dir = File.expand_path("../..", __FILE__)
working_directory app_dir


# Set unicorn options
worker_processes 2
preload_app true
timeout 30

# Set up socket location
listen(30000, backlog: 64) #if ENV['RAILS_ENV'] == 'development'

# Logging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{app_dir}/pids/unicorn.pid"
