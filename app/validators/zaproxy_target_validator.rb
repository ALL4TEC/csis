# frozen_string_literal: true

require 'uri'

class ZaproxyTargetValidator < ActiveModel::Validator
  def validate(record)
    return if /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/.match?(record.target)

    record.errors.add :target, I18n.t('activerecord.errors.models.scan_configuration.target')
  end
end
