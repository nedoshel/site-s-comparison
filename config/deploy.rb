# -*- coding: utf-8 -*-
require "rvm/capistrano"
require "bundler/capistrano"

ssh_options[:forward_agent] = true
ssh_options[:port] = 22

set :rails_env,   "production"
set :app_env,     "production"

set :app_port, 80
set :server_name, "sites_comparison"
set :sudo_user, :deploy
set :application, "sites_comparison"

set :rvm_type, :user
set :rvm_ruby_string, "ruby-1.9.3-p448"
#set :rvm_ruby_string, :local
set :default_shell, :bash
set :rvm_bin_path, "/usr/local/rvm"

set :application, "sites_comparison"
set :deploy_to, "~/sites_comparison"
set :scm, :git
set :repository,  "https://github.com/nedoshel/site-s-comparison.git"

set :scm_verbose, true
set :branch, "master"

set :user, "root"

set :use_sudo, true
set :keep_releases, 2

role :app, "94.127.66.69"
role :web, "94.127.66.69"
role :db,  "94.127.66.69"

set :bundle_cmd, "/usr/local/rvm/gems/#{rvm_ruby_string}@global/bin/bundle"
set :bundle_dir, "/usr/local/rvm/gems/#{rvm_ruby_string}"
# set :passenger_port, 3010
# set :passenger_cmd,  "#{bundle_cmd} exec passenger"

before "deploy", "deploy:setup"
before "deploy:assets:precompile", "db:config"
after "deploy", "db:migrate", "deploy:cleanup", "assets:precompile", "db:seed"
after "deploy", "assets:symlinks"
after "deploy", "server:restart"

  namespace :server do
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

    # task :config do
    #   run "cp -f #{deploy_to}/database.yml #{current_release}/config"
    # end
    #bundle exec rake db:create RAILS_ENV=production

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
      run "mkdir -p #{deploy_to}/shared/ckeditor_assets"
      # /shared/ckeditor_assets => /current/public/ckeditor_assets
      run "ln -s #{deploy_to}/shared/ckeditor_assets #{deploy_to}/current/public/ckeditor_assets"   
    end
    task :precompile, roles: :web, except: { no_release: true } do
      run "cd #{latest_release}; bundle exec rake assets:precompile RAILS_ENV=production"
    end
  end

end
