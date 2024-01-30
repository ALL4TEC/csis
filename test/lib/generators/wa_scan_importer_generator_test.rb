# frozen_string_literal: true

require 'test_helper'
require 'generators/wa_scan_importer/wa_scan_importer_generator'

class WaScanImporterGeneratorTest < Rails::Generators::TestCase
  tests WaScanImporterGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
