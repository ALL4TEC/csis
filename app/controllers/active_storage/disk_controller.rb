# frozen_string_literal: true

class ActiveStorage::DiskController < ActiveStorage::BaseController
  include ActiveStorage::FileServer
  skip_forgery_protection
  include PunditController
  before_action :authenticate_user_no_redir!

  def show
    if (key = decode_verified_key)
      serve_file named_disk_service(key[:service_name]).path_for(key[:key]),
        content_type: key[:content_type], disposition: key[:disposition]
    else
      head :not_found
    end
  rescue Errno::ENOENT
    head :not_found
  end

  def update
    if (token = decode_verified_token)
      if acceptable_content?(token)
        named_disk_service(token[:service_name]).upload token[:key], request.body,
          checksum: token[:checksum]
        head :no_content
      else
        head :unprocessable_entity
      end
    else
      head :not_found
    end
  rescue ActiveStorage::IntegrityError
    head :unprocessable_entity
  end

  private

  def named_disk_service(name)
    ActiveStorage::Blob.services.fetch(name) do
      ActiveStorage::Blob.service
    end
  end

  def decode_verified_key
    key = ActiveStorage.verifier.verified(params[:encoded_key], purpose: :blob_key)
    key&.deep_symbolize_keys
  end

  def decode_verified_token
    token = ActiveStorage.verifier.verified(params[:encoded_token], purpose: :blob_token)
    token&.deep_symbolize_keys
  end

  def acceptable_content?(token)
    token[:content_type] == request.content_mime_type &&
      token[:content_length] == request.content_length
  end
end
