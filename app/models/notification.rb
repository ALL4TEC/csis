# frozen_string_literal: true

#                   Modèle Notification
#
# Le modèle Notification permet d'informer les utilisateurs de l'application des
# nouveautés les intéressant.

class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers
  include EnumSelect

  NOTIFICATION_DATA = {
    create: {
      icon: Icons::MAT[:plus_one],
      color: 'trivial'
    },
    update: {
      icon: Icons::MAT[:edit],
      color: 'medium'
    },
    destroy: {
      icon: Icons::MAT[:less_one],
      color: 'critical'
    },
    warning: {
      icon: Icons::MAT[:warning],
      color: 'critical'
    }
  }.freeze

  validates :subject, presence: true

  default_scope -> { order(created_at: :desc).includes([{ version: :item }]) }

  scope :old, -> { where(['created_at <= ?', 3.months.ago]) }

  belongs_to :version,
    class_name: 'PaperTrail::Version'
  delegate :item, to: :version
  delegate :changeset, to: :version
  delegate :event, to: :version
  delegate :item_type, to: :version

  has_many :notifications_subscriptions,
    class_name: 'NotificationSubscription',
    inverse_of: :notification,
    primary_key: :id,
    dependent: :delete_all

  has_many :subscribers, through: :notifications_subscriptions

  enum_with_select :subject, {
    action_state_update: 0,
    comment_creation: 1,
    export_generation: 2,
    scan_launch_done: 3,
    scan_created: 4,
    scan_destroyed: 5,
    exceeding_severity_threshold: 6
  }

  # Data
  def data
    case item
    when Action
      action_data
    when Comment
      comment_data
    when ReportExport
      report_export_data
    when ScanLaunch
      scan_launch_data
    when WaScan, VmScan
      scan_data
    when WaOccurrence, VmOccurrence
      occurrence_data
    else
      deleted_item_data
    end
  end

  def to_s
    "#{version.event} #{version.item_type}"
  end

  private

  def notification_icon(event)
    NOTIFICATION_DATA[event.to_sym][:icon]
  end

  def notification_color(event)
    NOTIFICATION_DATA[event.to_sym][:color]
  end

  def action_data
    prev_state = I18n.t("activerecord.attributes.action/state.#{changeset['state'][0]}")
    new_state = I18n.t("activerecord.attributes.action/state.#{changeset['state'][1]}")
    {
      path: action_path(item),
      title: item.name,
      message: "#{prev_state}  >>>>  #{new_state}"
    }
  end

  def comment_data
    {
      path: action_path(item.action),
      title: item.action.name,
      message: I18n.t('notifications.comment.create'),
      icon: Icons::MAT[:comment]
    }
  end

  def report_export_data
    {
      path: report_exports_path(item.report),
      title: item.report.title,
      message: I18n.t('notifications.export.update'),
      icon: Icons::MAT[:download]
    }
  end

  def scan_launch_data
    {
      path: report_scan_launches_path(item.report),
      title: item.report.title,
      message: I18n.t('notifications.scan_launch.done', target: item.target),
      icon: Icons::MAT[:launch]
    }
  end

  def scan_data
    msg = I18n.t("notifications.scan.#{event}", scan_name: item.to_s)
    icon = notification_icon(event)
    if item.account.present?
      {
        path: send(:"#{item.kind_accro}_scan_path", item),
        title: item.account.type.delete_suffix('Config'),
        message: msg,
        icon: icon
      }
    else
      {
        path: report_scan_imports_path(item.scan_import&.report_scan_import&.report),
        title: item.scan_import&.report_scan_import&.report&.title,
        message: msg,
        icon: icon
      }
    end
  end

  def occurrence_data
    report = item.scan.reports.first
    msg = I18n.t('notifications.occurrence.warning',
      severity: AggregatesHelper.translate_severity(
        report.project.notification_severity_threshold
      ))
    icon = notification_icon('warning')
    {
      path: report_path(report),
      title: item.scan.to_s,
      message: msg,
      icon: icon
    }
  end

  def deleted_item_data
    # Item is nil here
    # For VmScan, no name but title, will change when merging common Qualys fields
    msg = if (names = version.changeset[:name]).present?
            names.first.presence || names.last
          else
            ''
          end
    {
      path: dashboard_path,
      title: I18n.t("notifications.#{item_type.underscore.split('_').last}.#{event}d"),
      message: msg
    }
  end
end
