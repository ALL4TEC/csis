# frozen_string_literal: true

class CronValidator < ActiveModel::Validator
  def validate(record)
    val = record.send(options[:field])
    return if val.blank? || Fugit::Cron.new(val).present?

    record.errors.add(options[:field], :invalid)
  end
end
