# frozen_string_literal: true

module ClientsHelper
  def discarded_color(discarded)
    discarded ? 'danger' : 'success'
  end

  def project_owner_color(type)
    type == 'client' ? 'success' : 'muted'
  end
end
