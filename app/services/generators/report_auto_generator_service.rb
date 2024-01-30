# frozen_string_literal: true

module Generators
  class ReportAutoGeneratorService
    class << self
      # Select last scans matching project regex not used by a report
      # among project.usable_#{kind}_scans: all in common between teams linked to project
      # + manually imported
      # @param **project:**
      # @param **kind:** vm or wa
      def select_last_scans_matching_project_regex(project, kind)
        day_zero = Time.zone.at(0)
        last_report = project.report
        last_report_edited_at = last_report.present? ? last_report.edited_at : day_zero
        project.send(:"usable_#{kind}_scans")
               .where('name ~* ? and launched_at > ?', project.scan_regex, last_report_edited_at)
               .order(launched_at: :desc)
               .select { |scan| scan.send(:"report_#{kind}_scans").count.zero? }
      end

      # @param **project_id:** Project id to auto generate report from
      def generate(project_id)
        project = Project.find(project_id)
        return unless project.auto_generate

        scans = []
        KindUtil.scan_accros.each do |kind|
          scans += select_last_scans_matching_project_regex(project, kind)
        end
        # Create a report only if scans matching
        return if scans.blank?

        previous, new_report = ReportManager.create(project)
        add_scans_to_new_report(scans, new_report, previous)

        # On copie les occurrences en commun et leurs agrégats
        ReportService.handle_occurrences(new_report, previous)
        # Exporting report to PDF
        return unless project.auto_export

        exporter = previous.present? ? previous.staff : project.staffs.first
        ex = ReportExport.create(report: new_report, exporter: exporter,
          status: :scheduled)
        Generators::ScanReportGeneratorJob.perform_later(nil, ex.id, false, true)
      end

      def add_scans_to_new_report(scans, new_report, previous)
        scans.each do |scan|
          ProjectService.add_scan_to_new_report(new_report, previous, scan)
        end
      end
    end
  end
end
