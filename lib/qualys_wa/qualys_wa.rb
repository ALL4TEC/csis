# frozen_string_literal: true

module QualysWa; end

class QualysWa::Error < StandardError; end

require 'common/xml'
require 'qualys_wa/request'
require 'qualys_wa/web_app'
require 'qualys_wa/vulnerability'
require 'qualys_wa/scan'
require 'qualys_wa/scan_test'
require 'qualys_wa/scan_result'
require 'qualys_wa/webapp'
