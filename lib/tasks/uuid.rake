require 'securerandom'

namespace :uuid do
  task :gen, [] => [:environment] do |task|
    puts SecureRandom.uuid
  end
end