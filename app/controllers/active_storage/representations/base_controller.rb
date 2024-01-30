# frozen_string_literal: true

class ActiveStorage::Representations::BaseController < ActiveStorage::BaseController # :nodoc:
  include ActiveStorage::SetBlob
  include PunditController

  before_action :authenticate_user_no_redir!
  before_action :authorize!
  before_action :set_representation

  private

  def blob_scope
    ActiveStorage::Blob.scope_for_strict_loading
  end

  def set_representation
    @representation = @blob.representation(params[:variation_key]).processed
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    head :not_found
  end

  def authorize!
    authorize(@blob)
  end
end
