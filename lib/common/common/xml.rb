# frozen_string_literal: true

module Common
  module Xml
    def get_xpath(data, xpath)
      data&.at_xpath(xpath)
    end

    def get_attr_value(data, xpath)
      get_xpath(data, xpath)&.value
    end

    def get_text(data, xpath)
      get_xpath(data, xpath)&.text&.strip
    end
  end
end
