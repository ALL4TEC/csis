# frozen_string_literal: true

require 'nokogiri'
require 'test_helper'

class CertificateTest < ActiveJob::TestCase
  test 'set correct sync link' do
    certificate = Certificate.first
    assert(certificate.certificates_languages.map(&:sync_link).none?, 'sync_link already present')
    certificate.update_certificate
    link = Certificate.find(certificate.id).certificates_languages.first.sync_link
    doc = Nokogiri::HTML(link)
    assert_not(doc.xpath('//a[@target=\'popup\']').empty?, 'Target is not popup!')
    assert_not(doc.xpath('//a[@href]').empty?, 'link href is not present')
    assert_not(doc.xpath('//img[@src]').empty?, 'image src is not present')
    assert(/.*1x{1}.*,{1}.*2x{1}.*/.match?(link),
      'image srcset contains 2 images 1x 2x')
    assert_not(doc.xpath("//img[@alt='#{Certificate::IMG_ALT}']").empty?, 'Bad image alt')
  end

  test 'certificate job scheduling' do
    certificate = Certificate.first
    assert(certificate.certificates_languages.map(&:sync_link).none?, 'sync_link already present')
    assert_enqueued_with(job: Generators::CertificateGeneratorJob) do
      certificate.update_certificate
    end
  end

  test 'link creation' do
    certificate = Certificate.first
    assert(certificate.certificates_languages.map(&:sync_link).none?, 'sync_link already present')
    certificate.update(project: Project.first)
    certificate.update(language_ids: Language.first.id)
    certificate.create_link(Language.first)
  end
end
