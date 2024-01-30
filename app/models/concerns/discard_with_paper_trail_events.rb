# frozen_string_literal: true

# Module including Discard::Model,
# Adding scope :trashed
# Adding discard and undiscard paper_trail events
# Stop using simple has_paper_trail...
module DiscardWithPaperTrailEvents
  module Model
    extend ActiveSupport::Concern

    included do
      include Discard::Model
      has_paper_trail

      scope :trashed, -> { with_discarded.discarded }
      before_discard ->(obj) { obj.paper_trail_event = 'discard' }
      before_undiscard ->(obj) { obj.paper_trail_event = 'undiscard' }
    end
  end
end
