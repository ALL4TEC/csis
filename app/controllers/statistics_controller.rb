# frozen_string_literal: true

require 'csv'

class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_project, only: %i[index update_certificate]
  before_action :set_collection_section_header, only: %i[show]
  before_action :set_member_section_header, only: %i[index]
  before_action :set_export_section_header, only: %i[export]

  SELECTABLE_OBJECTS = {
    'action' => Action,
    'report' => Report,
    'project' => Project
  }.freeze
  LIMIT = 5

  # Override CSP config only for statistics page due to chart.js styling ...
  content_security_policy only: %i[index show] do |policy|
    policy.style_src :self, :https, :unsafe_inline
  end

  # page statistics avec toutes les stats
  # GET /statistics
  # POST /statistics
  def index
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @project.name, project_path(@project)
    add_breadcrumb t('statistics.name')
    @projectstat = @project.statistics
    @certificate = @project.certificate
    @repartition_of_system_vulnerabilities = count_vulnerabilities(:system)
    @repartition_of_applicative_vulnerabilities = count_vulnerabilities(:applicative)
  end

  # onglet statistics
  # GET /statistics
  def show
    add_home_to_breadcrumb
    add_breadcrumb t('statistics.section_title')
    @projects = policy_scope(Project)
    # Si pas de param => on affiche simplement le formulaire
    # Sinon on récupère les données souhaitées et on affiche le(s) graphique(s) concerné(s)
    # Si les identifiants des rapports sont présents, on travaille sur l'intersection des rapports
    # disponibles pour le user
    # i.e. current_user.projects.map(&:report).compact
    # Si les types de vulnérabilité sont présents on les ajoute 1 par 1 dans un tableau pour
    # boucler dessus
    return if params[:view].blank?

    @graphs = []
    @limit = (params[:limit].presence || LIMIT).to_i
    case params[:view].to_i
    when 0
      kinds = set_kinds
      set_reports
      build_chart(kinds, :present, nil)
    when 1
      # Last vulnerabilities in OWASP Top 10
    when 2
      kinds = set_kinds
      set_reports
      build_chart(kinds, :critical, ApplicationHelper.severity_colors)
    when 3
      set_selected_projects
      # Last reports ordered by level/scoring VM/scoring WA with average
      @graphs << {
        kind: :pie,
        data: projects_levels,
        title: t('statistics.labels.projects_security_levels'),
        colors: ApplicationHelper.severity_colors,
        empty: :data
      }
      @graphs << {
        kind: :bar,
        data: projects_scores,
        title: t('statistics.labels.projects_scores'),
        colors: ApplicationHelper.scan_type_colors,
        empty: :data
      }
    else
      logger.error "Statistics: Unavailable operation specified #{params[:view]}"
    end
  end

  # Change the transparency_level status by clicking the go! button in stat/index.html.erb
  # POST /projects/:project_id/statistics/update_certificate
  def update_certificate
    certificate = Certificate.where(project: @project).first
    cert_param = params[:certificate]
    blank = %i[transparency_level language_ids].any? { |para| cert_param[para].blank? }
    raise MissingRequiredParameterError, __method__.to_s if blank

    level = cert_param[:transparency_level]
    invalid_trans = !level.in?(Certificate.transparency_levels)
    raise InvalidParameterError, level if invalid_trans

    if certificate.update(transparency_level: level,
      language_ids: cert_param[:language_ids])
      certificate.update_certificate
      flash.now[:notice] = t('certificate.sentences.update')
    else
      flash[:alert] = t('certificate.sentences.update_error')
    end
    redirect_to project_statistics_path
  end

  # GET /statistics/export
  def export
    tmp = {}

    SELECTABLE_OBJECTS.each do |o, klass|
      columns = {}
      klass.exportable_columns.each do |c|
        columns.merge!({ c => I18n.t("activerecord.attributes.#{o}.#{c}") })
      end

      tmp.merge!({ o => {
        name: I18n.t("models.#{o}"),
        columns: columns
      } })
    end

    @objects = tmp.to_json
  end

  # Ajouter le filtrage par policies
  # POST /statistics/export
  def generate
    begin
      klass = SELECTABLE_OBJECTS.fetch(params[:object]) # Throw KeyError if not found
      columns = params[:columns]
      if columns.present? && (columns - klass.exportable_columns).empty?
        scopes = policy_scope(klass)
        filename, data = ::Generators::StatisticsGeneratorService.generate_csv(
          klass, columns, scopes
        )
      else
        alert = I18n.t('statistics.exports.errors.wrong_columns')
      end
    rescue KeyError
      alert = I18n.t('statistics.exports.errors.wrong_object')
    end

    respond_to do |format|
      format.csv do
        if data.present?
          send_data data, filename: filename
        else
          redirect_to statistics_export_path, alert: alert
        end
      end
    end
  end

  private

  def authorize!
    authorize(Statistic)
  end

  def set_collection_section_header
    @app_section = make_section_header(title: t('statistics.section_subtitle.statistics'))
  end

  def set_member_section_header
    projects_headers = ProjectsHeaders.new
    headers = policy_headers(
      :statistic, :member, nil, ProjectPolicy.new(current_user, @project)
    ).filter
    @app_section = make_section_header(
      title: @project.name,
      subtitle: @project.client,
      scopes: projects_headers.tabs(headers[:tabs], @project),
      actions: projects_headers.actions(headers[:actions], @project),
      other_actions: projects_headers.actions(headers[:other_actions], @project)
    )
  end

  def set_export_section_header
    @app_section = make_section_header(title: t('statistics.exports.section_title'))
  end

  def count_vulnerabilities(kind)
    @project.aggregates
            .not_false_positive.where(kind: kind).group(:severity).order(severity: :desc)
            .count
  end

  def set_project
    store_request_referer(projects_path)
    handle_unscoped { @project = policy_scope(Project).find(params[:project_id]) }
  end

  def filter_vulns(agg_kind, kinds)
    @reports.flat_map { |r| r.send(:"#{agg_kind}_vulns") }
            .select { |v| v.kind_before_type_cast.in?(kinds) }
  end

  ### CHARTS
  def most_present_vulns(agg_kind, kinds)
    vulns = filter_vulns(agg_kind, kinds)
    t_vulns = vulns.count
    t_perc_a = []
    data = vulns.map(&:title)
                .group_by(&:itself)
                .map do |key, value|
                  p = ((value.count * 100).to_f / t_vulns).round(2)
                  t_perc_a << p
                  [p, key]
                end
    # Thanks rubocop ... Maybe should i split it into a method, maybe not
    data = data.sort
               .map { |k, v| [v, k] }
               .reverse
               .take(@limit - 1)
    t_perc_a = t_perc_a.sort.reverse
    if data.present?
      total_perc = t_perc_a.first(@limit - 1).sum.round(2)
      data << [t('statistics.labels.others'), (100 - total_perc).round(2)] if total_perc < 100
    end
    data
  end

  def most_critical_vulns(agg_kind, kinds)
    vulns = filter_vulns(agg_kind, kinds)
    t_vulns = vulns.count
    severities = []
    Vulnerability.severities.each do |s|
      severities << [AggregatesHelper.translate_severity(s[0]), 0]
    end
    vulns.map(&:severity)
         .group_by(&:itself)
         .each do |k, v|
           severities[Vulnerability.severities[k]][1] += ((v.count * 100).to_f / t_vulns).round(2)
         end
    severities.reverse
  end

  def projects_scores
    scoring_vm_h = { name: 'VM', data: [] }
    scoring_wa_h = { name: 'WA', data: [] }
    return nil if @s_projects.count.zero?

    scoring_vm = []
    scoring_wa = []
    @s_projects.each do |project|
      report = project.report
      next if project.report.blank?

      scoring_vm_h[:data] << [project.name, report.scoring_vm]
      scoring_vm << report.scoring_vm
      scoring_wa_h[:data] << [project.name, report.scoring_wa]
      scoring_wa << report.scoring_wa
    end
    avg_vm = scoring_vm.sum(0.0) / scoring_vm.size
    avg_wa = scoring_wa.sum(0.0) / scoring_wa.size
    t_avg = t('labels.average')
    t_min = 'Minimum'
    t_max = 'Maximum'
    scoring_vm_h[:data] += [[t_avg, avg_vm], [t_min, scoring_vm.min], [t_max, scoring_vm.max]]
    scoring_wa_h[:data] += [[t_avg, avg_wa], [t_min, scoring_wa.min], [t_max, scoring_wa.max]]
    [scoring_vm_h, scoring_wa_h]
  end

  def projects_levels
    total = @s_projects.count
    return nil if total.zero?

    levels = [
      [t('statistics.labels.nof_in_progress'), 0],
      [t('statistics.labels.nof_satisfactory'), 0],
      [t('statistics.labels.nof_good'), 0],
      [t('statistics.labels.nof_very_good'), 0],
      [t('statistics.labels.nof_excellent'), 0]
    ]
    @s_projects.map(&:current_level)
               .group_by(&:itself)
               .each do |k, v|
                 levels[Statistic.current_levels[k]][1] += ((v.count * 100).to_f / total).round(2)
               end
    empty_data_if_all_zero(levels)
  end

  def set_kinds
    # On enlève les information_gathered
    kinds = [Vulnerability.kinds.values.drop(1)]
    if params[:kinds].present? && !params[:kinds][0].to_i.zero?
      kinds = []
      params[:kinds].each { |k| kinds << k.to_i }
    end
    kinds
  end

  def set_reports
    projects = policy_scope(Project)
    @reports = if params[:reports].present?
                 Report.find(projects.map { |p| p.report&.id } & params[:reports])
               else
                 projects.filter_map(&:report)
               end
  end

  def set_selected_projects
    projects = policy_scope(Project)
    @s_projects = if params[:projects].present?
                    Project.find(projects.ids & params[:projects])
                  else
                    projects
                  end
  end

  def t_kind(kind)
    if kind.is_a?(Array)
      t('scopes.all')
    else
      t("activerecord.attributes.vulnerability/kind.#{Vulnerability.kinds.keys[kind]}")
    end
  end

  def empty_data_if_all_zero(data)
    data.all? { |group| group[1].zero? } ? [] : data # Empty array si aucune vuln
  end

  # **@param kinds :** Vulnerability kind
  def build_chart(kinds, method, colors)
    kinds.each do |k|
      KindUtil.scan_accros.each do |agg_k|
        kind_array = k.is_a?(Array) ? k : [k]
        data = send(:"most_#{method}_vulns", agg_k, kind_array)
        data = empty_data_if_all_zero(data)
        t_k = t_kind(k)
        next if data.nil? # Si nil on n'affiche rien

        @graphs << {
          kind: :pie,
          agg_kind: KindUtil.from_accro(agg_k.to_s),
          data: data,
          title: t("statistics.labels.last_most_#{method}_#{agg_k}_vulnerabilities", kind: t_k),
          colors: colors,
          empty: :vulnerability
        }
      end
    end
  end
end
