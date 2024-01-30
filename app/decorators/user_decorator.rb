# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  def full_name_and_email
    "#{object.full_name} (#{object.email})"
  end

  delegate :id, to: :object
end
