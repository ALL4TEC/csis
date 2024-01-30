# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    contact? || staff?
  end

  def toggle_default_card?
    contact? || staff?
  end

  def vulnerabilities_occurencies?
    staff?
  end

  def last_reports?
    staff? || contact?
  end

  def last_wa_scans?
    staff?
  end

  def last_vm_scans?
    staff?
  end

  def last_active_actions?
    contact?
  end

  def action_includes
    if staff?
      nil
    else
      [:receiver, { aggregates: :report }]
    end
  end

  def report_includes
    if staff?
      %i[project language]
    else
      [:project]
    end
  end

  def board_blocs
    board = %w[projects reports actions]
    if staff?
      custom_board = %w[teams scans]
      custom_board << 'qualys_clients' if super_admin?
    else
      custom_board = %w[statistics]
    end
    board + custom_board
  end

  def permitted_cards
    if staff?
      %w[vulnerabilities reports wa-scans vm-scans]
    else
      %w[reports actions]
    end
  end
end
