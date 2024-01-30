# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  FROM_MAIL = ENV.fetch('DEFAULT_FROM_EMAIL', ENV.fetch('MAIL_USER_NAME', nil))

  LOGO = 'Logo.png'
  IMAGE_PNG = 'image/png'

  default from: FROM_MAIL
  layout 'mailer'

  before_action :add_inline_attachments!
  self.delivery_job = MailDeliveryJob

  private

  # Ajout des images
  def add_inline_attachments!
    AssetsUtil::WEBICONS.each_key do |social|
      attachments.inline[AssetsUtil::WEBICONS[social]] = {
        data: File.read(AssetsUtil.webicon(social)),
        mime_type: IMAGE_PNG
      }
    end
    attachments.inline[LOGO] = {
      data: File.read(AssetsUtil.mails_logo),
      mime_type: IMAGE_PNG
    }
  end
end
