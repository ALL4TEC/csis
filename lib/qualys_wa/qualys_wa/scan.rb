# frozen_string_literal: true

class QualysWa::Scan
  include Common::Xml

  NAME = './/name'
  LIST = './/list'

  attr_reader :id,
    :name,
    :reference,
    :type,
    :mode,
    :multi,
    :progressive_scanning,
    :web_apps,
    :dns_override_id,
    :dns_override_name,
    :web_app_auth_record_id,
    :web_app_auth_record_name,
    :scanner_appliance_type,
    :scanner_appliance_friendly_name,
    :cancel_option,
    :proxy_id,
    :proxy_name,
    :proxy_url,
    :auth_record_option,
    :profile_option,
    :scanner_option,
    :profile_id,
    :profile_name,
    :options,
    :launched,
    :launched_by_id,
    :launched_by_username,
    :launched_by_firstname,
    :launched_by_lastname,
    :status,
    :cancel_mode,
    :canceled_by_id,
    :canceled_by_username,
    :canceled_by_firstname,
    :canceled_by_lastname,
    :scan_duration,
    :crawl_duration,
    :test_duration,
    :links_crawled,
    :nb_requests,
    :results_status,
    :auth_status,
    :os,
    :vulns,
    :sensitive_contents,
    :informations_gathered,
    :send_mail

  def initialize(data)
    @id = get_text(data, './/id')
    @name = get_text(data, NAME)
    @reference = get_text(data, './/reference')
    @type = get_text(data, './/type')
    @mode = get_text(data, './/mode')
    @multi = get_text(data, './/multi')
    @progressive_scanning = get_text(data, './/progressiveScanning')
    target = get_xpath(data, './/target')
    extract_web_apps(target)
    dns_override = get_xpath(target, './/dnsOverride')
    @dns_override_id = get_text(dns_override, './/id')
    @dns_override_name = get_text(dns_override, NAME)
    web_app_auth_record = get_xpath(target, './/webAppAuthRecord')
    @web_app_auth_record_id = get_xpath(web_app_auth_record, './/id')
    @web_app_auth_record_name = get_xpath(web_app_auth_record, NAME)
    scanner = get_xpath(target, './/scannerAppliance')
    @scanner_appliance_type = get_text(scanner, './/type')
    @scanner_appliance_friendly_name = get_text(scanner, './/friendlyName')
    proxy = get_xpath(target, './/proxy')
    @proxy_id = get_text(proxy, './/id')
    @proxy_name = get_text(proxy, NAME)
    @proxy_url = get_text(proxy, './/url')
    @auth_record_option = get_text(target, './/authRecordOption')
    @profile_option = get_text(target, './/profileOption')
    @scanner_option = get_text(target, './/scannerOption')
    @cancel_option = get_text(target, './/cancelOption')
    extract_opts(data)
    profile = get_xpath(data, './/profile')
    @profile_id = get_text(profile, './/id')
    @profile_name = get_text(profile, NAME)
    @launched = Time.zone.parse(get_text(data, './/launchedDate'))
    launch = get_xpath(data, './/launchedBy')
    @launched_by_id = get_text(launch, './/id')
    @launched_by_username = get_text(launch, './/username')
    @launched_by_firstname = get_text(launch, './/firstName')
    @launched_by_lastname = get_text(launch, './/lastName')
    @status = get_text(data, './/status')
    @cancel_mode = get_text(data, './/cancelMode')
    cancel = get_xpath(data, './/canceledBy')
    @canceled_by_id = get_text(cancel, './/id')
    @canceled_by_username = get_text(cancel, './/username')
    @canceled_by_firstname = get_text(cancel, './/firstName')
    @canceled_by_lastname = get_text(cancel, './/lastName')
    @scan_duration = get_text(data, './/scanDuration')
    summary = get_xpath(data, './/summary')
    @crawl_duration = get_text(summary, './/crawlDuration')
    @test_duration = get_text(summary, './/testDuration')
    @links_crawled = get_text(summary, './/linksCrawled')
    @nb_requests = get_text(summary, './/nbRequests')
    @results_status = get_text(summary, './/resultsStatus')
    @auth_status = get_text(summary, './/authStatus')
    @os = get_text(summary, './/os')
    extract_vulns(data)
    extract_sensitive_contents(data)
    extract_igs(data)
    @send_mail = get_text(data, './/sendMail')
  end

  # Recherche des scans
  def self.list(account, opts = {})
    api = { path: 'search/was/wasscan/', method: 'POST', params: opts }
    QualysWa::Request.do_list(account, self, './/WasScan', api)
  end

  # Detail d'un scan pour update
  # @param scan_ref = qualys internal_id
  def self.get(account, scan_ref, opts = {})
    api = { path: "download/was/wasscan/#{scan_ref}", method: 'GET', params: opts }
    QualysWa::Request.do_singular(account, self, '//WasScan', api)
  end

  private

  def extract_web_apps(target)
    @web_apps = []
    web_app_list = get_xpath(get_xpath(target, './/webApps'), LIST)
    get_xpath(web_app_list, './/WebApp')&.each do |web_app|
      @web_apps << QualysWa::WebApp.new(web_app)
    end
    @web_apps << QualysWa::WebApp.new(get_xpath(target, './/webApp'))
  end

  def extract_opts(data)
    @opts = []
    opts = get_xpath(get_xpath(data, './/options'), LIST)
    get_xpath(opts, './/WasScanOption')&.each do |opt|
      @opts << get_text(opt, NAME)
    end
  end

  def extract_vulns(data)
    @vulns = []
    vulnerabilities = get_xpath(get_xpath(data, './/vulns'), LIST)
    get_xpath(vulnerabilities, './/WasScanVuln')&.each do |v|
      @vulns << QualysWa::Vulnerability.new(v)
    end
  end

  def extract_sensitive_contents(data)
    @sensitive_contents = []
    s_contents = get_xpath(get_xpath(data, './/sensitiveContents'), LIST)
    get_xpath(s_contents, './/WasScanSensitiveContent')&.each do |sc|
      @sensitive_contents << QualysWa::Vulnerability.new(sc)
    end
  end

  def extract_igs(data)
    @informations_gathered = []
    igs = get_xpath(get_xpath(data, './/igs'), LIST)
    get_xpath(igs, './/WasScanIg')&.each do |ig|
      @informations_gathered << QualysWa::Vulnerability.new(ig)
    end
  end
end
