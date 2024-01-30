gem 'optparse'

namespace :user do
  task :add_user_init, [:email, :name, :password, :bypass_email_confirmation] => [:environment] do |task, args|
    options = {}
    opts = OptionParser.new
    opts.banner = "Usage: rake user:add_user_init [options]"
    opts.on("-e", "--email ARG", String) { |email| options[:email] = email }
    opts.on("-n", "--name ARG", String) { |name| options[:name] = name }
    opts.on("-p", "--password ARG", String) { |password| options[:password] = password }
    opts.on("-b", "--bypass_email_confirmation ARG", String) do |bypass|
      options[:bypass_email_confirmation] = bypass.to_b
    end
    args = opts.order!(ARGV) {}
    opts.parse!(args)
    
    UserService.add_user_init(
      options[:email], options[:name], options[:password], options[:bypass_email_confirmation])
    exit
  end
end