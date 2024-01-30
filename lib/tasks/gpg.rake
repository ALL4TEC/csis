namespace :gpg do
  task :check, [:email, :key_path] => [:environment] do |task|
    puts "Validating GPGME version"
    p GPGME::Engine.info.first
    puts "GNUPGHOME="
    p ENV['GNUPGHOME']
    puts "Looking for available keys"
    key = Importers::GpgImporterService.import(args[:email], args[:key_path])
    puts 'Key: ', key
  end
end