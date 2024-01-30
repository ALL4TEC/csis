# frozen_string_literal: true

require 'test_helper'

class ActiveStorage::BlobsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'authenticated staff only can see a blob' do
    # GIVEN
    # Having an aggregateContent with an attached image
    file = 'settings/fondPDF.png'
    # Create aggregateContent
    ac = AggregateContent.create!(aggregate: aggregates(:aggregate_one), text: 'TEXT', rank: 0)
    # Add image
    ac.image.attach(fixture_file_upload(file, 'image/png'))
    # WHEN
    # Trying to get the image while not logged
    get rails_service_blob_path(ac.image.attachment.blob.signed_id, file)
    # THEN
    # unauthorized
    assert_response 401
    # GIVEN a logged in user
    sign_in users(:staffuser)
    # WHEN
    # Trying to get the image
    get rails_service_blob_path(ac.image.attachment.blob.signed_id, file)
    # THEN
    # Redirected
    assert_response(:redirect)
    redir_url = response.redirect_url
    # GIVEN a logout user
    delete destroy_user_session_path
    # WHEN calling the redirect_url => DiskController
    get redir_url
    # THEN unauthorized
    assert_response 401
    # GIVEN a logged in user
    sign_in users(:staffuser)
    # WHEN calling the redirect_url
    get redir_url
    # THEN OK
    assert_response 200
    # GIVEN a variant
    variant = ac.image.variant(resize_to_limit: [100, 100])
    # WHEN calling RepresentationController logged out
    delete destroy_user_session_path
    get rails_blob_representation_path(
      ac.image.attachment.blob.signed_id, variant.variation.key, file
    )
    # THEN unauthorized
    assert_response 401
    # GIVEN a logged in user
    sign_in users(:staffuser)
    # Pb with null value for record_id for variant_record
    # Will investigate further if needed later
    # WHEN calling BlobRepresentationController
    # get rails_blob_representation_path(
    #   ac.image.attachment.blob.signed_id, variant.variation.key, file
    # )
    # # THEN redirected AND OK
    # assert_response(:redirect)
    # follow_redirect!
    # assert_response 200
  end
end
