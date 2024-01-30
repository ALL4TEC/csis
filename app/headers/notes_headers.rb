# frozen_string_literal: true

class NotesHeaders < HeadersHandler
  TABS = {}.freeze

  ACTIONS = {
    new: {
      label: 'notes.actions.create',
      href: 'report_new_note_path(data)',
      icon: Icons::MAT[:add]
    },
    edit: {
      label: 'notes.actions.edit',
      href: 'edit_note_path(data)',
      icon: Icons::MAT[:edit]
    },
    destroy: {
      label: 'notes.actions.destroy',
      href: 'note_path(data)',
      method: :delete,
      icon: Icons::MAT[:delete],
      confirm: 'notes.actions.destroy_confirm'
    },
    restore: {
      label: 'notes.actions.restore',
      href: 'restore_note_path(data)',
      method: :put,
      icon: Icons::MAT[:restore],
      confirm: 'notes.actions.restore_confirm'
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
