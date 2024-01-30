# frozen_string_literal: true

class QualysClient < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  before_create do
    unless qualys_config.ext.consultants_kind?
      raise MethodNotAllowedError, 'Cannot create client for qualys express account !'
    end
  end

  self.abstract_class = true

  def to_s
    qualys_name
  end
end
