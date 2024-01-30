# frozen_string_literal: true

require 'test_helper'

class CertificatesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated staff can change certificates languages
        when updating certificates' do
    sign_in users(:staffuser)
    p = Project.first
    l = Language.ids
    post "/projects/#{p.id}/statistics/update_certificate", params:
    {
      certificate:
      {
        transparency_level: 'secretive',
        language_ids: l
      }
    }
    assert_equal I18n.t('certificate.sentences.update'), flash[:notice]
  end

  test 'authenticated staff cannot change certificates languages by any value' do
    sign_in users(:staffuser)
    p = Project.first
    assert_raises ActiveRecord::RecordNotFound do
      post "/projects/#{p.id}/statistics/update_certificate", params:
      {
        certificate:
        {
          transparency_level: 'secretive',
          language_ids: 'ABC'
        }
      }
    end
  end
end
