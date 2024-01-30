# frozen_string_literal: true

require 'json'

COVERAGE_FILE_PATH = 'coverage/.resultset.json'
raise 'No coverage file found' unless File.exist?(COVERAGE_FILE_PATH)

sqube = JSON.parse(File.read(COVERAGE_FILE_PATH))
final_json = {}
sqube.each_key do |key|
  final_json[key] = {
    'coverage' => sqube[key]['coverage'].transform_values { |objects| objects['lines'] },
    'timestamp' => Time.now.to_i
  }
end
puts JSON.dump(final_json)
