# frozen_string_literal: true

class VulnerabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize!
  before_action :set_whodunnit
  before_action :set_vulnerability, only: %i[show]
  before_action :set_section_header, only: %i[index burp qualys cve nessus zaproxy cyberwatch]

  def index
    list_vulnerabilities(Vulnerability.all)
  end

  def burp
    list_vulnerabilities(Vulnerability.burp_kb_type)
  end

  def qualys
    list_vulnerabilities(Vulnerability.qualys_kb_type)
  end

  def cve
    list_vulnerabilities(Vulnerability.cve_kb_type)
  end

  def nessus
    list_vulnerabilities(Vulnerability.nessus_kb_type)
  end

  def zaproxy
    list_vulnerabilities(Vulnerability.zaproxy_kb_type)
  end

  def cyberwatch
    list_vulnerabilities(Vulnerability.cyberwatch_kb_type)
  end

  def show
    common_breadcrumb
    add_breadcrumb "#{t('vulnerabilities.labels.qid')}: #{@vulnerability.qid}"
  end

  private

  def authorize!
    authorize(Vulnerability)
  end

  def common_breadcrumb
    add_home_to_breadcrumb
    add_breadcrumb t('vulnerabilities.section_title'), :vulnerabilities_url
  end

  def list_vulnerabilities(vulnerabilities)
    caller = caller_locations(1..1).first.label
    common_breadcrumb
    add_breadcrumb t("vulnerabilities.scopes.#{caller}.name") unless caller == 'index'
    @q_base = vulnerabilities
    @q = @q_base.ransack params[:q]
    @vulnerabilities = @q.result.page(params[:page]).per(params[:per_page])
    render 'index'
  end

  def set_vulnerability
    store_request_referer(vulnerabilities_path)
    handle_unscoped do
      vuln_policy = VulnerabilityPolicy::Scope.new(current_user, Vulnerability)
      @vulnerability = vuln_policy.resolve
                                  .includes(vuln_policy.send(:"#{params[:action]}_includes"))
                                  .find(params[:id])
    end
  end

  def set_section_header
    vuln_headers = VulnerabilitiesHeaders.new
    headers = policy_headers(:vulnerability, :collection).filter
    @app_section = make_section_header(
      title: t('vulnerabilities.section_title'),
      scopes: vuln_headers.tabs(headers[:tabs], Vulnerability),
      actions: vuln_headers.actions(headers[:actions], nil)
    )
  end
end
