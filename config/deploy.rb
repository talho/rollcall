# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'rollcall'
set :repo_url, 'git@github.com:talho/rollcall.git'
set :branch, "master"
set :scm, :git


# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ubuntu/#{fetch(:application)}"

# Default value for :linked_files is []
set :linked_files, %w{config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle}

# Default value for keep_releases is 5
set :keep_releases, 5

set :rvm1_ruby_version, "ruby-2.2.0@rollcall"

namespace :deploy do
  task :setup do
    on roles :app do
      execute :'mkdir', '-p', "#{shared_path}/config"
    end
  end

  before :setup, 'deploy:check:make_linked_dirs'

  before :setup, :create_framework do
    on roles :app do
      upload! 'config/application.yml', shared_path.join('config/application.yml')
    end
  end

  after :setup, :install_prereqs do
    on roles :app do
      execute :sudo, :"apt-get", :install, :'nodejs', :'git', :'libpq-dev', "-y"
    end
  end

  desc 'Seed'
  after :finishing, :seed do
    on roles :db do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:seed'
        end
      end
    end
  end

  before :'rvm1:install:rvm', :install_gpg_key do
    on roles :app do
      execute :gpg, '--keyserver hkp://keys.gnupg.net', '--recv-keys D39DC0E3'
    end
  end
  after :setup, 'rvm1:install:rvm'
  after :setup, 'rvm1:install:ruby'
  
  after 'deploy:publishing', 'deploy:restart'
  task :restart do
    invoke 'unicorn:restart'
  end
end
