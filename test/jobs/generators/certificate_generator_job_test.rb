# frozen_string_literal: true

require 'test_helper'
require 'utils/tmp_file_helper'

module Generators
  class CertificateGeneratorJobTest < ActiveJob::TestCase
    include TmpFileHelper

    # Testing static methods (aka Class methods)
    test 'set date function of number of reports' do
      assert_equal(
        I18n.t(CertificateGeneratorJob::T_DATE_THE),
        CertificateGeneratorJob.new.send(:date, 1),
        'date setter does not work for one report!'
      )
      assert_equal(
        I18n.t(CertificateGeneratorJob::T_DATE_SINCE),
        CertificateGeneratorJob.new.send(:date, 3),
        'date setter does not work for multiple reports!'
      )
    end

    # Testing generator
    test 'that certificate is generated' do
      rep = scan_reports(:mapui)
      certificate_infos(rep)
      tmp_file_path('fake_certificate.pdf')
      CertificateGeneratorJob.new.generate_pdf(
        rep.project,
        @tmp_file_path,
        Certificate.transparency_levels[:secretive]
      )
      assert(File.file?(@tmp_file_path), 'No file generated!')
    end

    test 'that certificate generation is performed with TL: secretive' do
      transparency = 0
      language = languages(:fr)
      certificate_test(transparency, language)
    end

    test 'that certificate generation is performed with TL: obfuscate' do
      transparency = 1
      language = languages(:fr)
      certificate_test(transparency, language)
    end

    test 'that certificate generation is performed with TL: clearness' do
      transparency = 2
      language = languages(:fr)
      certificate_test(transparency, language)
    end

    # Testing JobHandler
    test 'that JobHandler launches' do
      rep = scan_reports(:mapui)
      certificate_infos(rep)
      CertificateGeneratorJob.perform_now(rep.project, languages(:fr).iso)
      assert(true, 'Generation performed!')
    end

    private

    def certificate_infos(rep)
      # Avec les fixtures le path et sync_link ne sont pas set.
      # Visiblement ça ne passe pas par after_create
      rep.project.certificate.update_certificate
    end

    def certificate_test(transparency, language)
      cert = certificates(:certificate_one)
      cert.transparency_level = transparency
      cert.path = 'WSC_1x.png'
      cert.languages = [language]
      cert.save!
      cert.create_link(language)
      cert.project.make_folder
      CertificateGeneratorJob.perform_now(cert.project, language.iso)
      cl = cert.certificates_languages.where.not(sync_link: nil).first
      path = "public/#{cl.sync_link.split("'")[3].split('3000')[1][1..]}"
      assert(File.file?(path), 'No file generated!')
      FileUtils.remove_dir(File.dirname(path), force: true) # Clean folder for the next test
    end
  end
end
