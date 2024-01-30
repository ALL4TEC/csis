# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'redis'
require 'resque/tasks'
require 'resque/scheduler/tasks'

task 'resque:setup' => :environment

#namespace :resque do
#task :setup_schedule => :setup do
#  require 'resque-scheduler'

  # If you want to be able to dynamically change the schedule,
  # uncomment this line.  A dynamic schedule can be updated via the
  # Resque::Scheduler.set_schedule (and remove_schedule) methods.
  # When dynamic is set to true, the scheduler process looks for
  # schedule changes and applies them on the fly.
  # Note: This feature is only available in >=2.0.0.
  # Resque::Scheduler.dynamic = true #Doublon?
#end

#task :scheduler => :setup_schedule
#end

require_relative 'config/application'

Rails.application.load_tasks

# Replace yarn with npm
Rake::Task['yarn:install'].clear if Rake::Task.task_defined?('yarn:install')
Rake::Task['webpacker:yarn_install'].clear
Rake::Task['webpacker:check_yarn'].clear
Rake::Task.define_task('webpacker:verify_install' => ['webpacker:check_npm'])
Rake::Task.define_task('webpacker:compile' => ['webpacker:npm_install'])
