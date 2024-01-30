# frozen_string_literal: true

module AssetsUtil
  # Assets paths
  IMAGES_DIR = Rails.root.join('app/assets/images')
  FONTS_DIR = Rails.root.join('app/assets/fonts')
  MEDALS_DIR = IMAGES_DIR.join('medals')
  CERTIFICATES_DIR = IMAGES_DIR.join('certificates')
  MAILS_DIR = IMAGES_DIR.join('mails')
  PUBLIC_DIR = Rails.public_path
  WSC_DIR = PUBLIC_DIR.join('WSC')
  ICONS_DIR = IMAGES_DIR.join('icons')
  LOGOS_DIR = IMAGES_DIR.join('logos')
  # REPORTS LOGO
  REPORTS_LOGO_PATH = LOGOS_DIR.join('csis_logo_only.png')
  # MAILS LOGO
  MAILS_LOGO_PATH = MAILS_DIR.join('Logo.png')
  # CERTIFICATES
  DEFAULT_CERT_BG = CERTIFICATES_DIR.join('pdf_bg.jpg')
  # MAILS WEBICONS
  WEBICONS = {
    linkedin: 'webicon-linkedin.png',
    twitter: 'webicon-twitter.png',
    facebook: 'webicon-facebook.png',
    pinterest: 'webicon-pinterest.png',
    youtube: 'webicon-youtube.png'
  }.freeze

  class << self
    def reports_logo
      serve_file(
        Branding.singleton.reports_logo,
        REPORTS_LOGO_PATH
      )
    end

    def mails_logo
      serve_file(
        Branding.singleton.mails_logo,
        MAILS_LOGO_PATH
      )
    end

    def certificates_bg
      serve_file(
        Branding.singleton.certificate_bg,
        DEFAULT_CERT_BG
      )
    end

    def badge(level, variant = nil)
      serve_file(
        Branding.singleton.send(:"#{level}_badge"),
        MEDALS_DIR.join("badge_#{level}.png"),
        variant
      )
    end

    def wsc(size)
      serve_file(
        Branding.singleton.send(:"wsc_#{size}"),
        CERTIFICATES_DIR.join("WSC_#{size}.png")
      )
    end

    def webicon(social)
      serve_file(
        Branding.singleton.send(:"#{social}_webicon"),
        MAILS_DIR.join("webicon-#{social}.png")
      )
    end

    def serve_file(uploaded, default, variant = nil)
      uploaded.attached? ? serve_file_content(uploaded, variant) : default
    end

    def serve_file_content(attachment, variant = nil)
      content = variant.present? ? attachment.variant(variant) : attachment
      StringIO.open(content.download)
    end
  end
end
