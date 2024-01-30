# frozen_string_literal: true

class ProjectService
  class << self
    # Vérifie si une nouvelle occurrence de sévérité supérieure au seuil du projet
    # @param **project:** Project to get notification severity threshold
    # @param **scan:** Scan to search occurrences in
    def list_new_exceeding_threshold_occurrences(project, scan)
      # Sélection des occurrences du rapport précédent (aka anciennes)
      previous = project.report
      old_occ = previous.present? ? previous.send(:"#{scan.kind_accro}_occurrences") : []
      # Sélection des occurrences du scan supérieures au seuil
      threshold = project.notification_severity_threshold_before_type_cast
      exceeding_severity_threshold_scan_occs = scan.occurrences.select do |o|
        o.vulnerability.severity_before_type_cast >= threshold
      end
      # Sélection des NOUVELLES(= not in old_occ list) occurrences du scan supérieures au seuil
      exceeding_severity_threshold_scan_occs.select(&OccurrenceLambda.only_new(old_occ))
    end

    # @param **new_report:** New report to add scan to
    # @param **previous:** Base report for new_report
    # @param **scan:** Scan to add to new report
    def add_scan_to_new_report(new_report, previous, scan)
      scan.reports << new_report
      # = new_report.send("#{kind}_scans=", scan)
      # new_report contains scan here and ReportXXScan exists

      ReportScanService.send(
        :"set_new_report_#{scan.kind_accro}_scan_targets", scan, new_report, previous
      )
    end

    # Création d'une nouveau rapport de Scan
    # à partir des données du précédent rapport si existant
    # en duplicant les occurrences communes et leurs agrégats
    # et en auto agrégeant les occurrences restantes
    # ou en auto aggrégeant toutes les occurrences
    # @param **project:** Project to find previous report and create new in
    # @param **scan:** Scan to add to new report
    # @return **the newly created report**
    def create_report_for_project_and_new_scan(project, scan)
      previous_report, new_report = ReportManager.create(project)
      add_scan_to_new_report(new_report, previous_report, scan)
      ReportService.handle_occurrences(new_report, previous_report)
      new_report
    end

    # Notify new report staffs of occurrences exceeding severity threshold
    # @param **new_report:** New report
    # @param **exceeding_threshold_occurrences:** occurrences exceeding severity threshold
    def notify_and_mail(new_report, exceeding_threshold_occurrences)
      # Notifier les staffs du projet
      staffs = new_report.project.staffs
      additional_data = {
        report: new_report,
        occurrences: exceeding_threshold_occurrences
      }
      BroadcastService.notify(
        staffs, :exceeding_severity_threshold, exceeding_threshold_occurrences.first.versions.last,
        additional_data
      )
    end

    # Auto generate report for projects with a regex matching scan name and
    # **a notification severity threshold defined!** and
    # **at least one report!**
    # @param **scan:** The new scan to compare name with projects regexes
    def auto_generate_report_for_exceeding_threshold_occurrences(scan)
      # Vérif si une regex correspond
      Project.auto.each do |project|
        # On cherche parmi tous les projets ayant le flag auto
        # et défini un seuil de sévérité de notification
        # si le nom du scan match la regex du projet
        next unless project.scan_regex.present? &&
                    project.notification_severity_threshold &&
                    scan.name&.match?(Regexp.new(project.scan_regex))

        # Liste les nouvelles occurrences supérieures au seuil de criticité du projet
        exceeding_threshold_occurrences = list_new_exceeding_threshold_occurrences(project, scan)
        next if exceeding_threshold_occurrences.blank?

        # Créer un rapport si nouvelle occurrence et notifier les staffs
        new_report = create_report_for_project_and_new_scan(project, scan)
        notify_and_mail(new_report, exceeding_threshold_occurrences)
        break
      end
    end
  end
end
