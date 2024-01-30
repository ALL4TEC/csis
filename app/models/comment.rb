# frozen_string_literal: true

#                   Modèle Comment
#
# Le modèle Comment permet de commenter une action dans le but d'échanger ou de fournir des
# informations sur cette dernière.

class Comment < ApplicationRecord
  include DiscardWithPaperTrailEvents::Model

  after_create do
    # Add everyone who commented as receivers and notify them
    receivers = action.reviewers
    receivers << action.author
    receivers << action.receiver
    BroadcastService.notify(receivers.uniq.compact - [author], :comment_creation, versions.last)
  end

  belongs_to :action,
    -> { with_discarded },
    class_name: 'Action',
    inverse_of: :comments,
    primary_key: :id

  validates :comment, presence: true, length: {
    in: 3..1024, message: I18n.t('comments.notices.length')
  }

  belongs_to :author,
    class_name: 'User',
    inverse_of: :comments,
    primary_key: :id,
    optional: true
end
