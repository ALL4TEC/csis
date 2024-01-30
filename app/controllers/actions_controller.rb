# frozen_string_literal: true

class ActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[show updates] # Needs action infos
  before_action :set_whodunnit
  before_action :set_aggregate, only: %i[index new]
  before_action :set_action, only: %i[show edit update destroy comment restore]
  before_action :set_actions, only: %i[active clotured archived trashed]
  before_action :set_collection_section_header, only: %i[index]
  before_action :set_member_section_header, only: %i[show]
  before_action :set_list_section_header, only: %i[active clotured archived trashed]
  before_action :update_issues_status, only: %i[show edit]

  DEFAULT_SORT = ['meta_state asc', 'aggregate_severity desc', 'created_at desc'].freeze

  # TODO: vérifier que les ticketable_ids sélectionnés au new et à l'edit sont bien accessibles par
  # le receiver sélectionné
  # TODO: quand il y a 2 issues utilisant le même ticketable, ça fait des étincelles

  ### ENDPOINTS ###

  # <tt>GET /aggregates/:id/actions</tt>
  # Affichage des actions d'un aggrégat pour un membre du staff
  def index
    common_breadcrumb(@aggregate.report.project, @aggregate.report, @aggregate)
    # includes = ActionPolicy::Scope.new(current_user, Action).list_includes
    @actions = filtered_list(@aggregate.actions, DEFAULT_SORT)
  end

  # <tt>GET /reports/:id/actions</tt>
  def of_report
    aggregate_breadcrumb(@report)
    @q_base = @report.actions
    @q = @q_base.ransack params[:q]
    @q.sorts = DEFAULT_SORT if @q.sorts.empty?
    @actions = @q.result.page(params[:page]).per(params[:per_page])
    render 'reports/actions'
  end

  # <tt>GET /actions</tt>
  # Affichage des actions actives
  def active
    list_actions
  end

  # <tt>GET /actions/clotured</tt>
  # Affichage des actions clôturées
  def clotured
    list_actions
  end

  # <tt>GET /actions/archived</tt>
  # Affichage des actions archivées
  def archived
    list_actions
  end

  # <tt>GET /actions/trashed</tt>
  # Affichage des actions supprimées pour un membre du staff
  def trashed
    list_actions
  end

  # <tt>GET /actions/:id</tt>
  # Affichage d'une action, de ses détails ainsi que des commentaires qui lui sont associés
  def show
    authorize(@action)
    if staff_signed_in?
      common_breadcrumb(@action.project, @action.report, @action.aggregate)
    else
      add_home_to_breadcrumb
      add_breadcrumb t('actions.section_title'), :actions_url
      add_breadcrumb @action.project.name
      add_breadcrumb @action.report.title
      add_breadcrumb @action.aggregate.title
    end
    add_breadcrumb @action.name
    store_request_referer
    @comment = Comment.new
    @comments = @action.comments.order('created_at asc').page(params[:page]).per(params[:per_page])
  end

  # <tt>GET /aggregates/:id/actions/new</tt>
  # Formulaire de création d'une nouvelle action
  def new
    @action = Action.new(name: @aggregate.title)
    common_breadcrumb(@aggregate.report.project, @aggregate.report, @aggregate)
    title = t('actions.actions.create')
    add_breadcrumb title
    store_request_referer
    @app_section = make_section_header(
      title: title,
      actions: [ActionsHeaders.new.action(:back, back_in_history)]
    )
  end

  # <tt>GET /actions/:id/edit</tt>
  # Modification d'une action
  def edit
    @aggregate = @action.aggregate
    common_breadcrumb(@action.project, @action.report, @aggregate)
    name = @action.name
    add_breadcrumb name, action_url(@action)
    add_breadcrumb "#{t('actions.actions.edit')} #{name}"
    @app_section = make_section_header(
      title: t('actions.pages.edit', action: name),
      actions: [ActionsHeaders.new.action(:back, action_path(@action))]
    )
  end

  # <tt>POST /actions</tt>
  # Création d'une nouvelle action
  def create
    @action = Action.new(action_params)
    @action.author_id = current_user.id
    if @action.save
      # done after .save because need config ID to link it in ticket description
      @action.issues.each do |issue|
        TicketingService.create_ticket(issue: issue)
      end
      redirect_to new_action_dependency_path(@action), notice: t('actions.notices.created')
    else
      @app_section = make_section_header(
        title: t('actions.actions.create'),
        actions: [ActionsHeaders.new.action(:back, :actions)]
      )
      set_aggregate
      render 'new'
    end
  end

  # <tt>(PUT | PATCH) /actions/:id</tt>
  # MAJ d'une action
  def update
    if @action.update(action_params)
      flash[:notice] = t('actions.notices.maj')
    else
      flash[:alert] = t('actions.notices.incomplete')
    end
    redirect_to @action
  end

  # <tt>DELETE /actions/:id</tt>
  # Suppression (discard) d'une action
  def destroy
    @action.discard
    notice = t(
      'actions.notices.deleted_html',
      action: html_escape_once(@action.name),
      cancel: helpers.link_to(
        t('actions.actions.restore'),
        restore_action_path(@action),
        method: :put,
        data: {
          confirm: t(
            'actions.actions.restore_confirm',
            infos: html_escape_once(@action.name)
          )
        }
      )
    )
    redirect_to(back_in_history, notice: notice)
  end

  # <tt>PUT /actions/:id/restore</tt>
  # Restauration (undiscard) d'une action
  def restore
    if @action.undiscard
      redirect_to @action, notice: t('actions.notices.restored', action: @action.name)
    else
      redirect_to trashed_actions_path, alert: t('actions.notices.cannot_restore')
    end
  end

  # <tt>POST /actions/:id/comment</tt>
  # Ajout d'un commentaire
  def comment
    return unless params[:comment][:comment]

    com = params[:comment][:comment]
    comment = Comment.create(
      comment: com, action: @action, author: current_user
    )
    if comment.valid?
      flash[:notice] = t('comments.notices.created')
    else
      flash[:alert] = comment.errors.messages.values.flat_map { |i| i[0] }.join(',')
    end
    redirect_to @action
  end

  # <tt>POST /actions/updates</tt>
  # Mise à jour du state des actions spécifiées
  # (utilisé sur actions/_list et le bouton pour actions/show)
  def updates
    return unless params[:choice].present? && params[:do].present?

    targetted_action_ids = params[:choice]
    to_do = params[:do]
    back = request.referer
    if to_do == 'mail'
      authorize(Action, :bulk_mail?)
      bulk_mail(targetted_action_ids)
    elsif to_do == 'delete'
      authorize(Action, :bulk_delete?)
      back = bulk_delete(targetted_action_ids)
    elsif Action.states.key?(to_do)
      fake_action = Action.new(state: to_do)
      authorize(fake_action, :bulk_state_update?)
      bulk_state_update(to_do, targetted_action_ids)
    end
    # Brakeman report for potential unsafe redirect
    # In case of possible referer spoofing (seems difficult but ...)
    # url_from checks that url is local
    # bulk_delete method returns actions_path which is safe
    redirect_to url_from(back) || actions_path
  end

  private

  def authorize!
    authorize(Action)
  end

  def add_breadcrumb_base
    add_home_to_breadcrumb
    add_breadcrumb t('actions.section_title'), :actions_url
  end

  def common_breadcrumb(project, report, aggregate)
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb project.name, project_path(project)
    add_breadcrumb t('models.reports'), project_reports_path(project)
    add_breadcrumb report.title, report
    add_breadcrumb t('models.aggregates'), report_aggregates_path(report)
    add_breadcrumb aggregate.title, aggregate_path(aggregate)
    add_breadcrumb t('models.actions'), aggregate_actions_path(aggregate)
  end

  ### DATA HANDLERS ###
  def action_params
    # Here we can't use the pundit helper as require does not use model name
    # (as action is already used by rails)
    params.require(:act).permit(policy(Action).permitted_attributes)
  end

  def set_aggregate
    handle_unscoped do
      aggregate_policy = AggregatePolicy::Scope.new(current_user, Aggregate)
      @aggregate = aggregate_policy.resolve.includes(
        aggregate_policy.send(:"actions_#{params[:action]}_includes")
      ).find(params[:aggregate_id].presence || params[:act][:aggregate_id])
    end
  end

  def set_action
    store_request_referer(actions_path)
    handle_unscoped do
      action_policy = ActionPolicy::Scope.new(current_user, Action)
      scope = params[:action].in?(%w[trashed restore]) ? 'trashed' : 'all'
      @action = action_policy.resolve.includes(action_policy.send(:"#{params[:action]}_includes"))
                             .send(scope).find(params[:id])
    end
  end

  # Restreint le périmètre utilisateur
  # A noter que @actions sera souvent reset en prenant en compte le paramètre de recherche
  # ransack dans chaque méthode
  def set_actions
    action_policy = ActionPolicy::Scope.new(current_user, Action)
    @actions = action_policy.resolve.includes(action_policy.send(:"#{params[:action]}_includes"))
  end

  def filter_actions_function_of_due_date_status
    filtered_actions_ids = []
    return filtered_actions_ids if params[:q].blank? || params[:q]['due_date_status_in'].blank?

    params[:q]['due_date_status_in'].each do |due_date_status|
      filtered_actions_ids += @actions.send(Action.due_date_statuses[due_date_status]).pluck(:id)
    end
    filtered_actions_ids
  end

  # Affichage des actions en fonction de l'état
  def list_actions
    add_breadcrumb_base
    method = params[:action]
    add_breadcrumb t("actions.scopes.#{method}.name")
    # TODO: Refacto with filtered_list
    @q_base = @actions
    filtered_action_ids = filter_actions_function_of_due_date_status
    @q_base = @q_base.where(id: filtered_action_ids) if filtered_action_ids.present?
    @q = @q_base.ransack params[:q]
    @q.sorts = method == :trashed ? 'discarded_at desc' : DEFAULT_SORT if @q.sorts.empty?
    @actions = @q.result.page(params[:page]).per(params[:per_page])
    render method == :trashed ? 'trashed' : 'index'
  end

  ### HEADERS ###
  def set_collection_section_header
    a_title = @aggregate.title
    aggregates_headers = AggregatesHeaders.new
    @app_section = make_section_header(
      title: a_title,
      scopes: aggregates_headers.tabs(%i[details actions], @aggregate),
      actions: aggregates_headers.actions(%i[edit create_action], @aggregate),
      other_actions: [aggregates_headers.action(:destroy, @aggregate)],
      filter_btn: true
    )
  end

  def set_list_section_header
    actions_headers = ActionsHeaders.new
    @app_section = make_section_header(
      title: t('actions.section_subtitle'),
      scopes: actions_headers.tabs(policy_headers(:action, :list).tabs, @actions),
      filter_btn: true
    )
    @actions = handle_scope(params[:action])
  end

  def handle_scope(act)
    if act == 'trashed'
      @actions.trashed
    else
      @actions.kept.send(act)
    end
  end

  def set_member_section_header
    actions_headers = ActionsHeaders.new
    headers = policy_headers(:action, :member).filter
    actions = actions_headers.actions(headers[:actions], @action)
    actions += [actions_headers.action(:back, :actions)]
    @app_section = make_section_header(
      title: @action.name,
      scopes: actions_headers.tabs(headers[:tabs], @action),
      actions: actions,
      other_actions: actions_headers.actions(headers[:other_actions], @action)
    )
  end

  # Envoi de mail pour les actions sélectionnées
  # Fonction permettant d'appeler le mailer et de retourner la notification
  # @param targetted_action_ids: liste d'identifiants d'actions ciblées
  def bulk_mail(targetted_action_ids)
    if !ActionPredicate.same_receiver?(targetted_action_ids)
      flash.now[:alert] = t('actions.notices.receiver_error')
    elsif Action.find(targetted_action_ids.first).receiver.present?
      @rcv_user = Action.find(targetted_action_ids.first).receiver
      if @rcv_user.public_key
        UserMailer.action_crypted(@rcv_user, targetted_action_ids).deliver_later
      else
        UserMailer.action(@rcv_user).deliver_later
      end
      flash.now[:notice] = t('actions.notices.mail_success')
    else
      flash.now[:alert] = t('actions.notices.mail_fail')
    end
  end

  # Suppression des actions sélectionnées
  def bulk_delete(targetted_action_ids)
    policy_scope(Action).find(targetted_action_ids).each(&:discard)
    flash[:notice] = t('actions.notices.delete')
    # A la suppression d'une action sur /actions/:id, rediriger vers la page /actions
    actions_path
  end

  # Met à jour les actions et retourne la notification
  # @param new_state: nouvel état souhaité
  # @param targetted_action_ids: liste des identifiants d'actions ciblées
  def bulk_state_update(new_state, targetted_action_ids)
    errors = ''
    policy_scope(Action).includes(:aggregates, :author).in(targetted_action_ids).each do |a|
      a.state = new_state
      a.update_meta
      errors += "#{a.name} " unless a.save
    end
    if errors.empty?
      flash.now[:notice] = t('actions.notices.maj')
    else
      flash.now[:alert] = "#{t('actions.notices.maj_failed')} ( #{errors})"
    end
  end

  # Checks if all related issues still exist/are open on the remote ticketing tool
  # If they don't, update their status
  def update_issues_status
    @action.issues.each do |issue|
      TicketingService.update_ticket_status(issue: issue)
    end
  end
end
