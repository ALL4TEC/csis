# frozen_string_literal: true

class ScansController < ApplicationController
  before_action :authenticate_user!, only: %i[show]
  before_action :authenticate_user_no_redir!, only: %i[show_occurrence]
  before_action :authorize!
  before_action :set_scan
  before_action :set_occurrence, only: %i[show_occurrence]
  before_action :set_whodunnit

  def initialize
    models = self.class.name.delete_suffix('Controller')
    model = models.singularize
    @model_u = model.underscore
    @clazz = instance_eval(model)
    super
  end

  # GET /(vm|wa)_scans/:id
  # Affiche le détail d'un scan
  # + une colonne par sévérité contenant les occurrences de vulnérabilité sous forme d'étiquette
  # Le clic sur une étiquette déclenche un call AJAX pour afficher le détail de l'occurrence
  def show
    add_home_to_breadcrumb
    scan_name = @scan.to_s
    add_breadcrumb scan_name, send(:"#{@model_u}_path", @scan)
    @app_section = make_section_header(
      title: scan_name,
      subtitle: t('reports.labels.scan_date') + I18n.l(@scan.launched_at, format: :short_dmy)
    )
  end

  # AJAX GET /(vm|wa)_scans/:id/occurrences/:occurrence_id
  def show_occurrence
    render json: {
      title: render_to_string(partial: 'occurrences/occurrence_modal_title',
        locals: { occ: @occurrence }),
      titleBgColor: "btn-#{@occurrence.vulnerability.severity}",
      html: render_to_string(partial: 'occurrences/occurrence_modal', locals: { occ: @occurrence })
    }
  end

  private

  def authorize!
    authorize(@clazz)
  end

  def set_scan
    handle_unscoped do
      @scan = policy_scope(@clazz).find(params[:id])
    end
  end

  def set_occurrence
    handle_unscoped do
      @occurrence = @scan.occurrences.find(params[:occurrence_id])
    end
  end
end
