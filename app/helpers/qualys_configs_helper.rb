# frozen_string_literal: true

require 'styles'
module QualysConfigsHelper
  ACCOUNT_KIND_MAP = {
    consultants: { color: 'primary' },
    express: { color: 'secondary' }
  }.freeze

  def account_kind_color(kind)
    ACCOUNT_KIND_MAP[kind.to_sym][:color]
  end
end
