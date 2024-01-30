# frozen_string_literal: true

module Sellsy; end

class Sellsy::Error < StandardError; end

require 'sellsy/request'
require 'sellsy/contact'
require 'sellsy/client'
require 'sellsy/supplier'
