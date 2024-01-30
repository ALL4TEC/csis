# frozen_string_literal: true

# To parse this XML, add 'dry-struct' and 'dry-types' gems, then do:
#
#   with_secure_scan = WithSecure::Report.from_xml! "<...>"
#   puts with_secure_scan.report
#
# If from_xml! succeeds, the value returned matches the schema.

module WithSecure; end

require 'with_secure/information'
require 'with_secure/platform'
require 'with_secure/plugins'
require 'with_secure/report'
