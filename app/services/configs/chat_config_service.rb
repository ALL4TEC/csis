# frozen_string_literal: true

class Configs::ChatConfigService
  class << self
    def any_enabled_type
      ChatConfig.first_enabled_type
    end
  end
end
