# frozen_string_literal: true

class ReportManager
  class << self
    # @param **project:** Project to create a report from
    # @param **data_to_merge:** Data to override default attributes
    # @return tuple containing [previous, new_report]
    def create(project, data_to_merge = {})
      previous = project.report
      today = Time.zone.today
      scan_report_h = {
        title: "Automated Report #{project.name} #{today}",
        project: project,
        edited_at: today
      }
      if previous.present?
        scan_report_h[:staff] = previous.staff
        scan_report_h[:contacts] = previous.contacts
      else
        scan_report_h[:staff] = project.staffs.first
        scan_report_h[:contacts] = project.client.contacts
      end
      new_report = ScanReport.create!(scan_report_h.merge(data_to_merge))
      [previous, new_report]
    end
  end
end
