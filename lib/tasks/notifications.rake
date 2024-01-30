namespace :notifications do
  # Clear old notifications
  task :clear_old, [] => [:environment] do |task|
    Cleaners::NotificationCleaner.clear_old
  end

  # Clear linked to nil versions
  task :clear_linked_to_nil_version, [] => [:environment] do |task|
    Cleaners::NotificationCleaner.clear_linked_to_nil_version
  end

  # Clear all
  task :clear_all, [] => [:environment] do |task|
    Cleaners::NotificationCleaner.clear_all
  end
end
