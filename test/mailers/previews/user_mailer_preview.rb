# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def action_crypted
    UserMailer.action_crypted(User.first, [Action.first.id])
  end

  def action
    UserMailer.action(User.first)
  end

  def action_state_update_notification
    action = Action.first
    action.update(state: :assigned)
    notif = Notification.where(subject: :action_state_update).first
    UserMailer.action_state_update_notification(User.first, notif)
  end

  def action_state_update_notification_crypted
    action = Action.first
    action.update(state: :assigned)
    notif = Notification.where(subject: :action_state_update).first
    UserMailer.action_state_update_notification_crypted(User.first, notif)
  end

  def exceeding_severity_threshold_notification
    UserMailer.exceeding_severity_threshold_notification(User.first, nil, { report: Report.first })
  end

  def exceeding_severity_threshold_notification_crypted
    if VmScan.all.count.zero?
      VmScan.create!(
        reference: 'cdszfzg',
        scan_type: 'scheduled',
        launched_at: Time.zone.now,
        name: 'some scan',
        status: 'FINISHED',
        duration: '00:11:11'
      )
    end
    VmOccurrence.create!(
      fqdn: '', vulnerability: Vulnerability.first, scan: VmScan.first, ip: '204.210.106.69',
      false_positive: 0
    )
    UserMailer.exceeding_severity_threshold_notification_crypted(
      User.first, nil, { report: Report.first, occurrences: [VmOccurrence.first] }
    )
  end

  def comment_creation_notification
    notif = Notification.where(subject: :comment_creation).first
    UserMailer.comment_creation_notification(User.first, notif)
  end

  def comment_creation_notification_crypted
    notif = Notification.where(subject: :comment_creation).first
    UserMailer.comment_creation_notification_crypted(User.first, notif)
  end

  def export_generation_notification
    export = ReportExport.create!(report: Report.first, exporter: User.staffs.first)
    export.update(status: :generated)
    notif = Notification.where(subject: :export_generation).first
    UserMailer.export_generation_notification(User.first, notif)
  end

  def export_generation_notification_crypted
    export = ReportExport.create!(report: Report.first, exporter: User.staffs.first)
    export.update(status: :generated)
    notif = Notification.where(subject: :export_generation).first
    UserMailer.export_generation_notification_crypted(User.first, notif)
  end

  def scan_created_notification
    add_vm_scan
    notif = Notification.where(subject: :scan_created).first
    UserMailer.scan_created_notification(User.first, notif)
  end

  def scan_created_notification_crypted
    add_vm_scan
    notif = Notification.where(subject: :scan_created).first
    UserMailer.scan_created_notification_crypted(User.first, notif)
  end

  def scan_destroyed_notification
    add_vm_scan
    scan = VmScan.first
    scan.destroy
    notif = Notification.where(subject: :scan_destroyed).first
    UserMailer.scan_destroyed_notification(User.first, notif)
  end

  def scan_destroyed_notification_crypted
    add_wa_scan
    scan = WaScan.first
    scan.destroy
    notif = Notification.where(subject: :scan_destroyed).first
    UserMailer.scan_destroyed_notification_crypted(User.first, notif)
  end

  def scan_launch_done_notification
    build_scan_launch
    notif = Notification.where(subject: :scan_launch_done).first
    UserMailer.scan_launch_done_notification(User.first, notif)
  end

  def scan_launch_done_notification_crypted
    build_scan_launch
    notif = Notification.where(subject: :scan_launch_done).first
    UserMailer.scan_launch_done_notification_crypted(User.first, notif)
  end

  private

  def build_scan_launch
    scan_config = ScanConfiguration.create!(
      scanner: :zaproxy, launcher: User.first, scan_type: 'zap-full-scan',
      target: 'something', parameters: '-a, -j, -f openapi', auto_import: false
    )
    scan_launch = ScanLaunch.create!(
      scan_configuration: scan_config,
      report: Report.first
    )
    scan_launch.update(status: :done)
  end

  def add_vm_scan
    return unless VmScan.all.count.zero?

    qc = QualysConfig.create!(
      name: 'qualysConfig',
      login: 'something',
      password: 'password',
      url: 'someurl',
      vm_import_cron: '',
      wa_import_cron: ''
    )
    VmScan.create!(
      reference: 'cdszfzg',
      scan_type: 'scheduled',
      launched_at: Time.zone.now,
      name: 'some scan',
      status: 'FINISHED',
      duration: '00:11:11',
      account: qc
    )
  end

  def add_wa_scan
    return unless WaScan.all.count.zero?

    WaScan.create!(
      reference: '12345',
      scan_type: 'scheduled',
      launched_at: Time.zone.now,
      name: 'some scan',
      status: 'FINISHED'
    )
  end
end
