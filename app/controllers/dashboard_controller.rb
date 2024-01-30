# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user_no_redir!, only: %i[vulnerabilities_occurencies last_reports
                                                       last_wa_scans last_vm_scans
                                                       last_active_actions]
  before_action :authenticate_user!, only: %i[toggle_default_card index]
  before_action :set_whodunnit
  before_action :authorize!
  LIMIT = 10

  # POST /dashboard/default_card
  def toggle_default_card
    # On set la dashboard_default_card du current_user avec la valeur envoyée en paramètre
    # seulement si la valeur est parmi celles autorisées
    # Si la valeur correspond à celle déjà définie, on clean la dashboard_default_card
    new_value = params[:view]
    if new_value.in?(policy(:dashboard).permitted_cards)
      new_value = '' if current_user.current_dashboard_default_card == new_value
      current_user.update_current_dashboard_default_card(new_value)
    end
    redirect_to dashboard_path
  end

  # GET /dashboard/vulnerabilities
  def vulnerabilities_occurencies
    @projects = policy_scope(Project)
    # Gestion de la limite et pagination possibles ici
    @vulnerabilities = vuln_card.last(LIMIT)
  end

  # GET /dashboard/last_reports
  def last_reports
    @reports = policy_scope(Report).includes(policy(:dashboard).report_includes)
                                   .order('edited_at desc').limit(LIMIT)
  end

  # GET /dashboard/last_wa_scans
  def last_wa_scans
    @wa_scans = policy_scope(WaScan).includes(qualys_wa_client: :teams).with_attached_landing_page
                                    .limit(LIMIT)
  end

  # GET /dashboard/last_vm_scans
  def last_vm_scans
    @vm_scans = policy_scope(VmScan).includes(:targets, qualys_vm_client: :teams).limit(LIMIT)
  end

  # GET /dashboard/last_active_actions
  def last_active_actions
    # Only for contacts today
    @actions = policy_scope(Action).active.includes(policy(:dashboard).action_includes)
                                   .order('created_at desc').limit(LIMIT)
  end

  # GET /dashboard
  def index
    @dashboard_policy = policy(:dashboard)

    @actions_sum = make_sum(policy_scope(Action).active)
    @actions_count = @actions_sum.each_value.sum

    @projects_sum = make_sum(policy_scope(Project))
    @projects_count = @projects_sum.each_value.sum

    @reports_sum = make_sum(policy_scope(Report))
    @reports_count = @reports_sum.each_value.sum

    @vm_scans_count = policy_scope(VmScan).count

    @wa_scans_count = policy_scope(WaScan).count
  end

  private

  def authorize!
    authorize(:dashboard)
  end

  # Take a collection of objects and return a hash {key => count(occurrences), ...}
  def make_sum(collection)
    sym = if collection.first.is_a?(Report)
            :level
          elsif collection.first.is_a?(Project)
            :current_level
          elsif collection.first.is_a?(Action)
            :severity
          end
    collection.map(&sym).group_by(&:itself).transform_values(&:size)
  end

  def vuln_card
    # compact supprime les nils
    reports = @projects.filter_map(&:report)

    # On charge les vulns wa et vm des derniers rapports des projets visibles par le user
    # Puis on map juste la severité et le qid
    # que l'on regroupe
    # on a alors le count disponible pour avoir la donnée sous forme [count, severité, qid]
    # que l'on trie (en commençant par le count(1er champ du tableau) par défaut)
    reports.flat_map(&:raw_vulnerabilities)
           .map { |v| [v.severity_before_type_cast, v.qid] }
           .group_by(&:itself)
           .map { |key, value| [value.count] + key }
           .sort

    # On doit donc ensuite boucler sur la liste précédente et pour chaque item boucler
    # sur tous les projets pour savoir s'ils contiennent la-dite vulnérabilité dans leur
    # dernier rapport pour pouvoir afficher le nom du projet
  end
end
