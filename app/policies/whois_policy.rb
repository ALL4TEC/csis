# frozen_string_literal: true

class WhoisPolicy < ApplicationPolicy
  def whois?
    staff? || contact?
  end
end
