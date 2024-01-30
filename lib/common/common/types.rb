# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Common
  module Types
    include Dry.Types()

    Hash   = Strict::Hash
    String = Strict::String
  end
end
