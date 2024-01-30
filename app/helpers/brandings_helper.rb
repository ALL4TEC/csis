# frozen_string_literal: true

module BrandingsHelper
  # WEB DOC
  CERTIFICATES_LINK = ''
  BG_PDF = 'certificates/pdf_bg.jpg'
  WSC_PREFIX = 'certificates/WSC'
  BADGES_PREFIX = 'medals/badge'
  REPORTS_LOGO = 'logos/csis_logo_only.png'
  MAILS_LOGO = 'mails/Logo.png'
  MAILS_WEBICONS_PREFIX = 'mails/webicon'

  def certificates_bg
    ternary_attachment(Branding.singleton.certificate_bg, BG_PDF)
  end

  def reports_logo
    ternary_attachment(Branding.singleton.reports_logo, REPORTS_LOGO)
  end

  def mails_logo
    ternary_attachment(Branding.singleton.mails_logo, MAILS_LOGO)
  end

  def wsc(size, variant = nil)
    attachment = Branding.singleton.send(:"wsc_#{size}")
    ternary_attachment(attachment, "#{WSC_PREFIX}_#{size}.png") do
      ternary_variant(attachment, variant)
    end
  end

  def badge(level, variant = nil)
    attachment = Branding.singleton.send(:"#{level}_badge")
    ternary_attachment(attachment, "#{BADGES_PREFIX}_#{level}.png") do
      ternary_variant(attachment, variant)
    end
  end

  def webicon(social)
    ternary_attachment(
      Branding.singleton.send(:"#{social}_webicon"), "#{MAILS_WEBICONS_PREFIX}-#{social}.png"
    )
  end

  private

  def ternary_attachment(attachment, default, &block)
    if block
      attachment.attached? ? yield : default
    else
      attachment.attached? ? attachment : default
    end
  end

  def ternary_variant(attachment, variant = nil)
    variant.present? ? attachment.variant(variant) : attachment
  end
end
