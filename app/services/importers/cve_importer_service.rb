# frozen_string_literal: true

module Importers
  class CveImporterService
    # @param job: job créé à l'initialisation du perform
    def initialize(job)
      @job = job
    end

    def handle_vuln_import(file, vulnerability_import)
      @job.update!(status: :opening_document)
      Rails.logger.debug { "Opening file at: #{file.path}" }
      json = JSON.parse(file.read)
      @job.update!(status: :looking_for_issues)
      json['CVE_Items'].each do |vuln|
        description = vuln['cve']['description']['description_data'].first['value']
        next if description.start_with?('** REJECT **')

        cve = Nist::Cve.new(vuln)
        @job.update!(status: :handle_issues)
        handle_vulnerability(cve, vulnerability_import)
      end
      @job.update!(status: :update_status)
      vulnerability_import.update(status: :completed)
    end

    def import_vulns(vulnerability_import)
      vulnerability_import.document.open do |file|
        handle_vuln_import(file, vulnerability_import)
      end
    end

    private

    def update_vulnerability(vuln, cve, vulnerability_import)
      # update vulnerability if present
      vuln.update!(CveMapper.cve_to_h(cve, vulnerability_import))
    end

    def create_vulnerability(cve, vulnerability_import)
      # create vulnerability if not present
      Vulnerability.create!(CveMapper.cve_to_h(cve, vulnerability_import))
    end

    def handle_vulnerability(cve, vulnerability_import)
      vuln = Vulnerability.cve_kb_type.find_by(title: cve.title)
      if vuln.present?
        last_update = vuln.updated_at.presence
        last_update ||= vuln.created_at.presence # Si pas d'updated_at
        if last_update.to_i < cve.modified.to_i
          update_vulnerability(vuln, cve, vulnerability_import)
        else
          vuln
        end
      else
        create_vulnerability(cve, vulnerability_import)
      end
    end
  end
end
