# frozen_string_literal: true

class QualysConfigExt < ApplicationRecord
  self.table_name = :qualys_configs
  include EnumSelect

  belongs_to :qualys_config, inverse_of: :ext

  enum_with_select :kind, { consultants: 0, express: 1 }, suffix: true
end
