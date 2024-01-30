# frozen_string_literal: true

class AggregatesController < ApplicationController
  AJAX_ACTIONS = %i[reorder merge bulk_duplicate bulk_delete].freeze
  before_action :authenticate_user!, except: AJAX_ACTIONS
  before_action :authenticate_user_no_redir!, only: AJAX_ACTIONS
  before_action :authorize!
  before_action :set_whodunnit

  before_action :set_report, only: %i[index new create reorder save_order apply_order bulk_delete]
  before_action :set_aggregate, only: %i[show edit update destroy up down toggle_visibility
                                         edit_attachment update_attachment merge]
  before_action :set_create_section_header, only: %i[new create]
  before_action :set_edit_section_header, only: %i[edit]
  before_action :set_collection_section_header, only: %i[index save_order apply_order]
  before_action :set_member_section_header, only: %i[show]

  AGGREGATES_ACTIONS_CREATE = 'aggregates.actions.create'
  MODELS_AGGREGATES = 'models.aggregates'
  AVAILABLE_ORDER = {
    severity: 'severity desc',
    status: Aggregate.by_status_desc,
    visibility: 'visibility',
    title: 'title'
  }.freeze

  def prepare_index
    common_breadcrumb(@report)
    add_breadcrumb t(MODELS_AGGREGATES)
    includes = AggregatePolicy::Scope.new(current_user, Aggregate).list_includes
    Aggregate.where(report: @report).order(:rank).includes(includes)
  end

  # <tt>GET /reports/:report_id/aggregates</tt>
  def index
    aggs = prepare_index
    @org_aggregates = aggs.organizational_kind
    @sys_aggregates = aggs.system_kind
    @app_aggregates = aggs.applicative_kind
    return unless pentest?

    @vulnerability_scan = aggs.vulnerability_scan_kind
    @appendix = aggs.appendix_kind
  end

  # <tt>PUT /reports/:id/aggregates/order</tt> aka order_report_aggregates_path
  # Save order list in related report
  # Then apply_order
  def save_order
    permitted_params = params.permit(aggregates_order_by: [])
    known_order_by = permitted_params[:aggregates_order_by].all? do |order|
      order.to_sym.in?(AVAILABLE_ORDER.keys)
    end
    @report.update!(permitted_params) if known_order_by
    apply_order
  end

  # <tt>POST /reports/:id/aggregates/apply_order</tt> aka apply_order_report_aggregates_path
  # Apply report order list of related report
  # Then render index with modified bg-color for aggregates rank save buttons
  # bg-color is then removed when clicking on each button
  def apply_order
    aggs = prepare_index
    order = @report.aggregates_order_by.map do |o|
      AVAILABLE_ORDER.fetch(o.to_sym)
    end
    @org_aggregates = aggs.organizational_kind.reorder(order) # Throw KeyError if not found
    @sys_aggregates = aggs.system_kind.reorder(order) # Throw KeyError if not found
    @app_aggregates = aggs.applicative_kind.reorder(order) # Throw KeyError if not found
    render 'index'
  end

  # <tt>GET /aggregates/:id</tt>
  def show
    report = @aggregate.report
    common_breadcrumb(report)
    add_breadcrumb t(MODELS_AGGREGATES), report_aggregates_path(report)
    add_breadcrumb @aggregate.title
  end

  # <tt>GET /reports/:report_id/aggregates/new</tt>
  def new
    common_breadcrumb(@report)
    add_breadcrumb t(AGGREGATES_ACTIONS_CREATE)
    @aggregate = Aggregate.new
    init_occurrences(@report)
    @contents = [] if pentest?
  end

  # <tt>GET /aggregates/:id/edit</tt>
  def edit
    edit_data
  end

  # <tt>POST /reports/:report_id/aggregates</tt>
  def create
    if params[:aggregate][:kind].in? Aggregate.kinds.keys[2..3]
      params[:aggregate].merge!(
        severity: :falsepositive,
        status: :information_gathered,
        visibility: :shown
      )
    end
    Aggregate.transaction do
      @aggregate = Aggregate.new(aggregate_params)
      @aggregate.report = @report
      init_occurrences(@report)
      max_rank = Aggregate.where(report: @report, kind: params[:aggregate][:kind])
                          .order('rank desc').pick(:rank) || 0
      @aggregate.rank = max_rank + 1
      @aggregate.save!
    end
    handle_contents if pentest?
    redirect_to report_aggregates_path(@report)
  rescue ActiveRecord::RecordInvalid
    @contents = [] if pentest?
    common_breadcrumb(@report)
    add_breadcrumb t(AGGREGATES_ACTIONS_CREATE)
    render 'new'
  end

  # <tt>POST /aggregates/:id/up</tt>
  def up
    move_aggregate
  end

  # <tt>POST /aggregates/:id/down</tt>
  def down
    move_aggregate(move_up: false)
  end

  # <tt>POST /aggregates/:id/toggle_visibility</tt>
  def toggle_visibility
    @aggregate.toggle_visibility
    flash[:notice] = t('aggregates.notices.visibility_updated')
    redirect_to report_aggregates_path(@aggregate.report)
  end

  # <tt>(PATCH | PUT) /aggregates/:id</tt>
  def update
    if @aggregate.update(aggregate_params)
      if @aggregate.report.is_a?(PentestReport) && Rails.application.config.pentest_enabled
        handle_contents
      end
      redirect_to report_aggregates_path(@aggregate.report)
    else
      edit_data
      add_breadcrumb Aggregate.find(@aggregate.id).title
      set_edit_section_header
      render 'edit'
    end
  end

  # <tt>DELETE /aggregates/:id</tt>
  def destroy
    report = @aggregate.report
    if @aggregate.discard
      flash[:notice] = t('aggregates.notices.deletion_success')
    else
      flash[:alert] = t('aggregates.notices.deletion_failure')
    end
    redirect_to report_aggregates_path(report)
  end

  # <tt>GET /aggregates/:id/edit_attachment</tt>
  def edit_attachment
    edit_attachment_data
  end

  # <tt>POST /aggregates/:id/update_attachment</tt>
  def update_attachment
    @aggregate.actions = @aggregate.report.project.actions
                                   .where(id: params[:aggregate][:action_ids])
    if @aggregate.save
      redirect_to report_aggregates_path(@aggregate.report),
        notice: t('aggregates.notices.attachment_success')
    else
      edit_attachment_data
      render 'edit_attachment'
    end
  end

  ### AJAX calls

  # DELETE /reports/:id/aggregates
  def bulk_delete
    # Check that all aggregates are from report
    aggregate_ids = ListFormatter.to_ary(params[:aggregate_ids])
    if aggregate_ids.blank?
      return render json: { status: :error, message: t('aggregates.delete.error.no_aggregate') }
    end

    @report.aggregates.find(aggregate_ids)&.each(&:discard)
    render json: { status: :ok }
  rescue StandardError => e
    render json: { status: :error, message: e.message }
  end

  # POST /aggregates/duplicate
  # For each report
  # Create an aggregate duplicate of aggregate_id in report if report has unaggregated occurrences
  # similar to aggregate one
  def bulk_duplicate
    # Check all params are present
    aggregate_ids = ListFormatter.to_ary(params[:aggregate_ids])
    report_ids = ListFormatter.to_ary(params[:report_ids])
    if aggregate_ids.blank?
      return render json: { status: :error, message: t('aggregates.duplicate.error.no_aggregate') }
    end
    if report_ids.blank?
      return render json: { status: :error, message: t('aggregates.duplicate.error.no_report') }
    end

    ReportService.bulk_duplicate_aggregates(report_ids, aggregate_ids)
    render json: { status: :ok }
  end

  # POST /reports/:id/aggregates/reorder
  def reorder
    aggregates = @report.aggregates.where(kind: params[:kind].to_sym)
    aggregates_list_size = aggregates.count
    # loop over aggregates data list to shift them
    update_aggregates_rank(aggregates, aggregates_list_size)
    # Re-loop over aggregates data list to set real position
    update_aggregates_rank(aggregates, 0)
    # Return aggregates of corresponding kind list ordered by rank asc
    render json: aggregates.order('rank asc').map(&:id).to_json
  end

  # PUT /aggregates/:id/merge
  def merge
    if (aggregate_ids = params[:aggregate_ids]).present?
      @aggregate = AggregateService.merge_aggregates(
        @aggregate, ListFormatter.to_ary(aggregate_ids)
      )
    end
    if (occurrences_data = params[:occurrences_data]).present?
      @aggregate = AggregateService.move_occurrences(@aggregate, JSON.parse(occurrences_data))
    end
    if @aggregate.save
      flash.now[:notice] = I18n.t('aggregates.notices.merge_success')
    else
      flash.now[:alert] = I18n.t('aggregates.notices.merge_failure')
    end
    render json: { status: :ok }
  rescue StandardError => e
    render json: { status: :error, message: e.message }
  end

  private

  def authorize!
    authorize(Aggregate)
  end

  def update_aggregates_rank(aggregates, shift)
    JSON.parse(params[:aggregates_data]).each do |aggregate_data|
      new_position = aggregate_data['position'] + shift
      aggregates.find(aggregate_data['id']).update(rank: new_position)
    end
  end

  SEVERITY_DESC = 'vulnerabilities.severity DESC'
  QID_ASC = 'vulnerabilities.qid ASC'
  IP_ASC = 'ip ASC'
  URI_ASC = 'uri ASC'

  def common_breadcrumb(report)
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb report.project.name, project_path(report.project_id)
    add_breadcrumb t('models.reports'), project_reports_path(report.project_id)
    add_breadcrumb report.title, report
  end

  def aggregate_params
    params.require(:aggregate).permit(policy(Aggregate).permitted_attributes)
  end

  # Init occurrences
  def init_occurrences(report)
    # @aggregate.new_record?
    @vm_selected = []
    @wa_selected = []
    vm_incl = report.unaggregated_vms.count.positive? ? [:vulnerability] : []
    wa_incl = report.unaggregated_was.count.positive? ? [:vulnerability] : []
    @vm_occurrences = VmOccurrence.in(report.unaggregated_vms).joins(:vulnerability)
                                  .order(QID_ASC, IP_ASC).includes(vm_incl)
    @wa_occurrences = WaOccurrence.in(report.unaggregated_was).joins(:vulnerability)
                                  .order(QID_ASC, URI_ASC).includes(wa_incl)

    # @vm_occurrences = report.unaggregated_vms
    # @wa_occurrences = report.unaggregated_was
  end

  # Move up aggregate by default
  # Specify up to false to move down
  def move_aggregate(move_up: true)
    next_rank = move_up ? @aggregate.rank - 1 : @aggregate.rank + 1
    swap(@aggregate.rank, next_rank, @aggregate.kind, @aggregate.report)
    redirect_to report_aggregates_path(@aggregate.report)
  end

  # Set all data needed when editing an aggregate
  # Method called if update fails
  def edit_data
    @report = @aggregate.report

    @vm_selected = @aggregate.vm_occurrences.includes(:vulnerability).order(QID_ASC, IP_ASC)
    @wa_selected = @aggregate.wa_occurrences.includes(:vulnerability).order(QID_ASC, URI_ASC)
    @vm_occurrences = VmOccurrence.in(@report.unaggregated_vms)
                                  .includes(:vulnerability)
                                  .order(SEVERITY_DESC, QID_ASC, IP_ASC)
    @wa_occurrences = WaOccurrence.in(@report.unaggregated_was)
                                  .includes(:vulnerability)
                                  .order(SEVERITY_DESC, QID_ASC, URI_ASC)

    # Comment faire pour que ceux en cours ne soient pas reset on error?
    @contents = @aggregate.contents.with_attached_image.order('rank asc') if pentest?

    common_breadcrumb(@report)
    add_breadcrumb t(MODELS_AGGREGATES), aggregate_path(@aggregate)
  end

  def edit_attachment_data
    report = @aggregate.report
    common_breadcrumb(report)
    add_breadcrumb t(MODELS_AGGREGATES), report_aggregates_path(report)
    add_breadcrumb @aggregate.title, @aggregate
    title = t('aggregates.labels.edit_attachment')
    add_breadcrumb title
    @app_section = make_section_header(
      title: title,
      actions: [AggregatesHeaders.new.action(:back, back_in_history)]
    )

    @actions = @aggregate.report.project.actions.order(created_at: :desc)
  end

  def set_aggregate
    store_request_referer(projects_path)
    handle_unscoped { @aggregate = policy_scope(Aggregate).find(params[:id]) }
  end

  def set_report
    store_request_referer(projects_path)
    handle_unscoped { @report = policy_scope(Report).find(params[:report_id] || params[:id]) }
  end

  def set_create_section_header
    create_edit_section_header(@report)
  end

  def set_edit_section_header
    create_edit_section_header(@aggregate.report)
  end

  def report_title(report)
    t('reports.pages.title', report: report.title, date: report.edited_at.strftime('%d/%m/%y'))
  end

  def report_subtitle(report)
    t('reports.pages.project', project: report.project, client: report.project.client)
  end

  def create_edit_section_header(report)
    clazz = report.type
    reports_headers = "#{clazz}sHeaders".constantize.new
    @app_section = make_section_header(
      title: report_title(report),
      subtitle: report_subtitle(report),
      actions: [reports_headers.action(:back, report_aggregates_path(report))]
    )
  end

  def set_collection_section_header
    clazz = @report.type
    reports_headers = "#{clazz}sHeaders".constantize.new
    headers = policy_headers(clazz, :member).filter
    oa = %i[auto_aggregate auto_aggregate_no_mixing] | headers[:other_actions]
    oa -= %i[create_aggregate]
    @app_section = make_section_header(
      title: report_title(@report),
      subtitle: report_subtitle(@report),
      scopes: reports_headers.tabs(headers[:tabs], @report),
      actions: reports_headers.actions(%i[create_aggregate] | headers[:actions], @report),
      other_actions: reports_headers.actions(oa, @report)
    )
  end

  def set_member_section_header
    a_title = @aggregate.title
    aggregates_headers = AggregatesHeaders.new
    @app_section = make_section_header(
      title: a_title,
      scopes: aggregates_headers.tabs(%i[details actions], @aggregate),
      actions: [aggregates_headers.action(:edit, @aggregate)],
      other_actions: [aggregates_headers.action(:destroy, @aggregate)]
    )
  end

  # Permet d'échanger le rank de deux agrégats d'un report
  def swap(left, right, kind, report)
    max = Aggregate.where(report: report, kind: kind)
                   .order('rank DESC').pick(:rank)
    if right.zero?
      update_aggregates_ranks(left, kind, report, max, 'ASC')
    elsif right == max + 1
      update_aggregates_ranks(left, kind, report, max, 'DESC')
    else
      a1 = Aggregate.find_by(report: report, kind: kind, rank: left)
      a2 = Aggregate.find_by(report: report, kind: kind, rank: right)
      Aggregate.transaction do
        a1.update(rank: 1024) # Hope no more than 1023 aggregates will be used
        a2.update(rank: left)
        a1.update(rank: right)
      end
    end
  end

  # Update aggregates ranks function of direction ASC or DESC
  def update_aggregates_ranks(left, kind, report, max, direction)
    # Includes report as Aggregate.before_update needs it
    Aggregate.where(report: report, kind: kind).order(rank: direction.to_sym).includes(:report)
             .each do |a|
      rank = direction == 'ASC' ? a.rank - 1 : a.rank + 1
      a.update(rank: rank)
    end
    previous_rank = direction == 'ASC' ? left - 1 : left + 1
    next_rank = direction == 'ASC' ? max : 1
    Aggregate.find_by(report: report, kind: kind, rank: previous_rank).update(rank: next_rank)
  end

  # Takes care of param[:contents]
  def handle_contents
    return if params[:contents].blank?

    contents = []

    params[:contents].values.each_with_index do |c, i|
      # Ne raise pas d'error si l'id est '' contrairement à find
      if (content = AggregateContent.find_by(id: c[:id]))
        content.text = c[:text]
        content.rank = i + 1
        content.save
      else
        content = AggregateContent.create(aggregate: @aggregate, text: c[:text], rank: i + 1)
      end
      handle_image(content, c[:image]) if c[:keep] == 'false'
      contents << content
    end
    @aggregate.update(contents: contents)
  end

  def handle_image(content, image)
    if image.present?
      content.image.attach(image)
    else
      content.image.purge
    end
  end

  def pentest?
    @report.is_a?(PentestReport) && Rails.application.config.pentest_enabled
  end
end
