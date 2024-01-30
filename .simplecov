# frozen_string_literal: true

if ENV['COVERAGE'] == 'true'
  SimpleCov.start 'rails' do
    puts 'SimpleCov started successfully !'
    track_files '{app,lib}/**/*.rb'
    add_filter '/test/'
    add_filter '/vendor/'
    add_filter '/config/'
    add_filter '/spec/'
    add_group 'Policies', 'app/policies'
    add_group 'Headers', 'app/headers'
    add_group 'Errors', 'app/errors'
    add_group 'Inputs', 'app/inputs'
    add_group 'Jobs', 'app/jobs'
    add_group 'Decorators', 'app/decorators'
    add_group 'Services', 'app/services'
    add_group 'Handlers', 'app/handlers'
    add_group 'Comparators', 'app/comparators'
    add_group 'Lambdas', 'app/lambdas'
    add_group 'Managers', 'app/managers'
    add_group 'Mappers', 'app/mappers'
    add_group 'Predicates', 'app/predicates'
    add_group 'Schedulers', 'app/schedulers'
  end

  SimpleCov.at_exit do
    puts 'SimpleCov exit'
    SimpleCov.result.format!
  end
end
