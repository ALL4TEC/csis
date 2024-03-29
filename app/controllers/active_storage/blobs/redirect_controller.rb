# frozen_string_literal: true

# Take a signed permanent reference for a blob and turn it into an expiring service URL for
# download.
# Note: These URLs are publicly accessible. If you need to enforce access protection beyond the
# security-through-obscurity factor of the signed blob references, you'll need to implement your
# own authenticated redirection controller.
class ActiveStorage::Blobs::RedirectController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include PunditController

  before_action :authenticate_user_no_redir!
  before_action :authorize!

  def show
    expires_in ActiveStorage.service_urls_expire_in
    redirect_to @blob.url(disposition: params[:disposition]), allow_other_host: true
  end

  private

  def authorize!
    authorize(@blob)
  end
end
