# frozen_string_literal: true

class DependenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!, except: %i[index]
  before_action :set_whodunnit
  before_action :set_action
  before_action :set_create_section_header, only: :new
  before_action :set_collection_section_header, only: %i[index]
  before_action :same_aggregate?, only: %i[create]

  # Affichage des dépendances pour un utilisateur autorisé
  def index
    # Here authorization needs @action record
    authorize(@action, policy_class: DependencyPolicy)
    if staff_signed_in?
      common_staff_breadcrumb
    else
      add_home_to_breadcrumb
      add_breadcrumb t('actions.section_title'), :actions_url
      add_breadcrumb @action.project.name
      add_breadcrumb @action.report.title
      add_breadcrumb @action.aggregate.title
    end
    add_breadcrumb @action.name, action_url(@action)
    add_breadcrumb t('models.dependencies')
    @q_base = @action.action_p.includes(:aggregates)
    @q = @q_base.ransack params[:q]
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @actions = @q.result.page(params[:page]).per(params[:per_page])
  end

  # Formulaire de création d'une nouvelle dépendance
  def new
    common_staff_breadcrumb
    add_breadcrumb @action.name, action_url(@action)
    add_breadcrumb t('actions.actions.create_dependency')
    @dependency = Dependency.new
  end

  # Création d'une nouvelle dépendance
  def create
    s = @action.id
    predecessors.each do |p|
      dependency = Dependency.new(predecessor_id: p.id, successor_id: s)
      next if dependency.save

      d = Dependency.trashed.where(predecessor_id: p.id, successor_id: s).first
      d.undiscard if d.present?
    end
    if dependency_params[:predecessor_id].count > 1
      flash[:notice] = t('dependencies.notices.done')
    else
      flash[:alert] = t('dependencies.notices.no_selection')
    end
    redirect_back_in_history
  end

  # Suppression de dépendances
  def updates
    if params[:choice].present?
      Dependency.where(predecessor_id: params[:choice], successor_id: @action.id).discard_all
      flash.now[:notice] = t('dependencies.notices.maj')
    else
      flash[:alert] = t('dependencies.notices.no_selection')
    end
    redirect_to action_dependencies_path(@action)
  end

  private

  def authorize!
    authorize(Dependency)
  end

  def common_staff_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('projects.section_title'), :projects_url
    add_breadcrumb @action.project.name, project_path(@action.project)
    add_breadcrumb t('models.reports'), project_reports_path(@action.project)
    add_breadcrumb @action.report.title, @action.report
    add_breadcrumb t('models.aggregates'), report_aggregates_path(@action.report)
    add_breadcrumb @action.aggregate.title, aggregate_path(@action.aggregate)
    add_breadcrumb t('models.actions'), aggregate_actions_path(@action.aggregate)
  end

  def dependency_params
    params.require(:dependency).permit(policy(Dependency).permitted_attributes)
  end

  def set_action
    @action = handle_unscoped { policy_scope(Action).find(params[:action_id]) }
  end

  def set_create_section_header
    @app_section = make_section_header(
      title: t('actions.actions.create_dependency'),
      subtitle: @action.name,
      actions: [ActionsHeaders.new.action(:back, action_dependencies_path(@action))]
    )
  end

  def set_collection_section_header
    actions_headers = ActionsHeaders.new
    headers_policy = policy_headers(:dependency, :collection).filter
    @app_section = make_section_header(
      title: @action.name,
      actions: actions_headers.actions(headers_policy[:actions], @action),
      other_actions: actions_headers.actions(headers_policy[:other_actions], @action),
      scopes: actions_headers.tabs(headers_policy[:tabs], @action)
    )
  end

  # Permet de faire le tri dans les dépendances : si A dépend de B ne pas créer deux dépendances
  # mais juste une dépendance à A.
  def predecessors
    @preds.each do |pred|
      next unless @preds.include?(pred)

      # On prend les predecesseurs suivant le predecesseur courant
      following_preds = @preds.drop(@preds.index(pred) + 1)
      following_preds.each do |following_pred|
        next if ActionPredicate.in_same_deps_tree?(pred, following_pred.id)

        # On enlève des prédecesseurs pred si ce n'est pas un successeur du following_pred
        # ET on enlève des prédecesseurs following_pred si pred n'est pas un predecesseur
        # de following_pred
        if !pred.succ?(following_pred.id)
          @preds -= Array(pred)
        elsif !pred.pred?(following_pred.id)
          @preds -= Array(following_pred)
          break
        end
      end
    end
    @preds
  end

  # Check that all action predecessors have same aggregate as action
  def same_aggregate?
    preds = params[:dependency][:predecessor_id]
    preds -= [''] # SimpleForm génère un hidden input "" pour ne pas POST de nil
    unless preds.count.positive?
      redirect_to aggregate_actions_path(@action.aggregate)
      return false
    end
    usable = Action.find(params[:action_id]).aggregate.action_ids
    if Action.in(preds).where.not(id: usable).exists?
      flash[:alert] = t('actions.notices.aggregate_error')
      redirect_back(fallback_location: root_path)
    else
      # On ne charge les includes que si plusieurs prédécesseurs, sinon aucun intérêt
      incl = Action.in(preds).count == 1 ? [] : %i[roots action_p action_s]
      @preds = Action.includes(incl).find(preds)
    end
  end
end
