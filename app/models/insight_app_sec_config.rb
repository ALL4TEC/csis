# frozen_string_literal: true

class InsightAppSecConfig < Account
  include ApiAccount

  validates :url, presence: true
end
