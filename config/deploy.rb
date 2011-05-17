default_run_options[:pty] = true
set :application, "subscriptus"
set :repository,  "git@github.com:codefire/#{application}"
set :scm, :git
set :deploy_to, "/home/deploy/apps/#{application}"
set :shared_dir, "shared"
set :use_sudo, false

task :to_staging do 
  set :user, "root"
  set :password, "zxnm9014"
  set :prod_db, "subscriptus"
  set :db_hostname, "localhost"
  set :db_port, 3306

  set :branch, "refctoring-mutator"

  role :app, "deploy@zebra.crikey.com.au"
  role :web, "deploy@zebra.crikey.com.au"
  role :db,  "deploy@zebra.crikey.com.au", :primary => true
end

task :to_production do 
  set :user, "root"
  set :password, "zxnm9014"
  set :prod_db, "subscriptus"
  set :db_hostname, "whitlam-back"
  set :db_port, 3306
  set :port, 2244 # SSH PORT

  role :app, "deploy@fraser.crikey.com.au"
  role :web, "deploy@fraser.crikey.com.au"
  role :db,  "deploy@fraser.crikey.com.au", :primary => true
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test cucumber postgres --path ~/apps/subscriptus/shared/bundle/"
  end
end

after "deploy:update_code" do
  bundler.bundle_new_release
end

desc "Create extra directories"
task :after_setup do
  run "mkdir -p #{deploy_to}/#{shared_dir}/config/"
end

before "deploy:symlink" do
  run "sudo monit stop delayed_job"
  sleep(15) # monit stop is non-blocking so this is a kludge ...
end

after "deploy:symlink" do

  template = File.read("config/database.yml.erb")
  database_configuration = ERB.new(template).result(binding)
  put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml" 
  run "rm -f #{release_path}/config/database.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"

  #run("cd #{deploy_to}/current; /usr/bin/rake db:migrate RAILS_ENV=production")

  run "sudo monit start delayed_job"
end

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
#    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end


namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  namespace :web do

    desc "Serve up a custom maintenance page."
    task :disable, :roles => :web do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      
      reason      = ENV['REASON']
      deadline    = ENV['UNTIL']
      
      template = File.read("app/views/layouts/maintenance.html.erb")
      page = ERB.new(template).result(binding)
      
      put page, "#{shared_path}/system/maintenance.html", 
                :mode => 0644
    end
  end
end



Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
