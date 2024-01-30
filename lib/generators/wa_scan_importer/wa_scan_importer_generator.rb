# frozen_string_literal: true

class WaScanImporterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def replace_mappings_in_service(_mappings)
    inject_into_file 'wa_scan_importer_service.rb',
      after: "#The code goes below this line. Don't forget the Line break at the end\n" do
      <<-RUBY
      puts mappings
      RUBY
    end
  end

  def copy_service_file(scanner_name)
    copy_file 'wa_scan_importer_service.rb',
      "app/services/#{scanner_name}_wa_scan_importer_service.rb"
  end
end
