# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'scanner'
set :repo_url, 'https://fraz017:imgreat1@github.com/fraz017/skyscanner.git'

set :branch, 'master'

set :deploy_to, '/www/sites/scanner'
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

set :passenger_restart_with_touch, true
# set :rvm_custom_path, '/usr/local/rvm'
# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/sidekiq.yml', 'config/initializers/sidekiq.rb')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :rails_env, 'production'

# Default value for keep_releases is 5
set :keep_releases, 2

set :rvm_ruby_version, '2.2.4'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'tmp:cache:clear'
      # end
    end
  end

  # task :seed do
  #   run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=production"
  # end
  
  after :finishing, 'deploy:restart'
end
