# frozen_string_literal: true

class ReportExportRefresher
  extend CableReady::Broadcaster

  EXPORTS_LIST_SEL = '#exports_list'

  class << self
    ### First version, not optimized, as update complete list
    ###
    # def refresh_list(report_export)
    #   # A chaque MAJ d'un export, on indique à cable_ready d'update la liste des exports
    #   # au cas où un des utilisateurs se trouve dessus
    #   report = report_export.report
    #   project = report.project
    #   possible_viewers = project.staffs + project.client.contacts
    #   possible_viewers.each do |user|
    #     cable_ready[UsersChannel].inner_html(
    #       selector: EXPORTS_LIST_SEL,
    #       html: ApplicationController.render(
    #         partial: 'exports/list', locals: { exports: report.exports }
    #       )
    #     ).broadcast_to(user)
    #   end
    # end

    ### Preferred way
    # Here we can send refresh or remove to a dom element, as action will be
    # done only for users having the dom element on their current interface,
    # thus subscribing to targeted resource
    ###

    # We send a notification to ReportsChannel:report_id to prepend
    # new report_export to '#exports_list'
    def add_to_list(report_export)
      report = report_export.report
      cable_ready[ReportsChannel].prepend(
        selector: EXPORTS_LIST_SEL,
        html: ApplicationController.render(report_export)
      ).broadcast_to(report)
    end

    # Morph report_export dom element with report_export html partial
    def refresh(report_export)
      report = report_export.report
      cable_ready[ReportsChannel].morph(
        selector: dom_id(report_export),
        html: ApplicationController.render(report_export)
      ).broadcast_to(report)
    end

    # Remove report_export dom element
    def remove_report_export(report_export)
      report = report_export.report
      cable_ready[ReportsChannel].remove(
        selector: dom_id(report_export)
      ).broadcast_to(report)
    end
  end
end
