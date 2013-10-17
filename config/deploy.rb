# -*- coding: utf-8 -*-
require "rvm/capistrano"
require "bundler/capistrano"

ssh_options[:forward_agent] = true
ssh_options[:port] = 22

set :rails_env,   "production"
set :app_env,     "production"

set :app_port, 80
set :server_name, "94.127.66.69"
set :sudo_user, :deploy
set :application, "94.127.66.69"

set :rvm_type, :user
set :rvm_ruby_string, "ruby-1.9.3-p448"

#set :default_shell, :bash
set :default_shell, "/bin/bash -l -c"
set :rvm_bin_path, "/usr/local/rvm/bin"

#set :application, "sites_comparison"
set :deploy_to, "/root/sites_comparison"
set :scm, :git
set :repository,  "https://github.com/nedoshel/site-s-comparison.git"

set :scm_verbose, true
set :branch, "master"

set :user, "root"

set :use_sudo, false
set :keep_releases, 2

role :app, "94.127.66.69"
role :web, "94.127.66.69"
role :db,  "94.127.66.69"

set :bundle_cmd, "/usr/local/rvm/gems/#{rvm_ruby_string}@global/bin/bundle"
set :bundle_dir, "/usr/local/rvm/gems/#{rvm_ruby_string}/bin"
# set :passenger_port, 3010
# set :passenger_cmd,  "#{bundle_cmd} exec passenger"

before "deploy", "deploy:setup"
before "deploy:assets:precompile", "db:config"
after 'deploy:update_code', "assets:symlinks"
after "deploy", "db:migrate"
after "deploy", "deploy:cleanup", "assets:precompile", "db:seed"
after "deploy", "thin:restart"

  namespace :thin do
    desc "Start the Thin processes"
    task :start do
      run  <<-CMD
        cd #{deploy_to} && bundle exec thin start -C config/thin.yml
      CMD
    end

    desc "Stop the Thin processes"
    task :stop do
      run <<-CMD
        cd #{deploy_to} && bundle exec thin stop -C config/thin.yml
      CMD
    end

    desc "Restart the Thin processes"
    task :restart do
      run <<-CMD
        cd #{deploy_to} && bundle exec thin restart -C config/thin.yml
      CMD
    end
  end


  namespace :db do
    desc <<-EOD
      operation with config and migrations
    EOD

    task :prepare do
      run " cd #{deploy_to} && bundle exec rake prepare[#{deploy_to}/current/db/migrate,#{previous_release}/db/migrate] "
    end

    task :migrate do
      run " cd #{deploy_to}/current && bundle exec rake db:migrate RAILS_ENV=production"
    end
    task :seed do
      run " cd #{deploy_to}/current && bundle exec rake db:seed RAILS_ENV=production"
    end
  end

  namespace :assets do
    task :symlinks, roles: :app do
      if !remote_file_exists?("#{deploy_to}/current/config/database.yml")
        run "ln -s #{deploy_to}/shared/database.yml #{latest_release}/config/database.yml"   
      end
    end
    task :precompile, roles: :web, except: { no_release: true } do
      run "cd #{latest_release}; bundle exec rake assets:precompile RAILS_ENV=production"
    end
  end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end