# frozen_string_literal: true

class Nist::Cve
  attr_reader :title,
    :description,
    :published,
    :modified,
    :category,
    :bugtraqs,
    :cvss_version,
    :cvss_vector,
    :cvss,
    :exploitability_score,
    :impact_score,
    :osvdb

  def initialize(data)
    # Vulnerability
    @published = data['publishedDate']
    @published = Time.zone.now if @published.blank?
    @modified = data['lastModifiedDate']
    @modified = @published if @modified.blank?
    # CVE
    cve = data['cve']
    @title = cve['CVE_data_meta']['ID']
    @category = cve['problemtype']['problemtype_data'].first['description'].first['value']
    @description = cve['description']['description_data'].first['value']
    @bugtraqs = []
    cve['references']['reference_data'].each do |ref|
      name = ref['name']
      source = ref['refsource']
      if source == 'OSVDB'
        @osvdb = name # Only store osvdb id
      else
        @bugtraqs << "#{source}:#{name}#{ref['tags']}(#{ref['url']})"
      end
    end
    impact = data['impact']
    if (base_data = impact['baseMetricV3']).present?
      handle_cvss_v3(base_data)
    elsif (base_data = impact['baseMetricV2']).present?
      handle_cvss_v2(base_data)
    end
  end

  private

  def handle_cvss_v2(base_data)
    cvss_data = base_data['cvssV2']
    @cvss = cvss_data['baseScore']
    @cvss_vector = cvss_data['vectorString']
    @cvss_version = cvss_data['version']
    @exploitability_score = base_data['exploitabilityScore']
    @impact_score = base_data['impactScore']
  end

  def handle_cvss_v3(base_data)
    cvss_data = base_data['cvssV3']
    @cvss = cvss_data['baseScore']
    @cvss_vector = cvss_data['vectorString']
    @cvss_version = cvss_data['version']
    @exploitability_score = base_data['exploitabilityScore']
    @impact_score = base_data['impactScore']
  end
end
