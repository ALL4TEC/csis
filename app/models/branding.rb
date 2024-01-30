# frozen_string_literal: true

class Branding < ApplicationRecord
  SIZES = {
    certificate_bg: '528x297',
    reports_logo: '50x50',
    mails_logo: '500x100',
    wsc: {
      '1x': {
        displayed: '182x74',
        expected: '182x74'
      },
      '2x': {
        displayed: '364x148',
        expected: '364x148'
      },
      full: {
        displayed: '364x148',
        expected: '2836x1418'
      }
    },
    badges: '200x200',
    webicons: '24x24'
  }.freeze

  # Reports
  has_one_attached :reports_logo
  # Mails
  has_one_attached :mails_logo
  has_one_attached :linkedin_webicon
  has_one_attached :twitter_webicon
  has_one_attached :facebook_webicon
  has_one_attached :pinterest_webicon
  has_one_attached :youtube_webicon
  # Certificates
  has_one_attached :certificate_bg
  has_one_attached :wsc_1x do |attachable|
    attachable.variant :thumb, resize_to_limit: [72, 36]
    attachable.variant :stats, resize_to_limit: [100, 50]
  end
  has_one_attached :wsc_2x
  has_one_attached :wsc_full
  has_one_attached :black_badge do |attachable|
    attachable.variant :pictured, resize_to_limit: [20, 20]
    attachable.variant :thumb, resize_to_limit: [36, 36]
    attachable.variant :stats, resize_to_limit: [100, 100]
    attachable.variant :certificate, resize_to_limit: [150, 150]
  end
  has_one_attached :bronze_badge do |attachable|
    attachable.variant :pictured, resize_to_limit: [20, 20]
    attachable.variant :thumb, resize_to_limit: [36, 36]
    attachable.variant :stats, resize_to_limit: [100, 100]
    attachable.variant :certificate, resize_to_limit: [150, 150]
  end
  has_one_attached :silver_badge do |attachable|
    attachable.variant :pictured, resize_to_limit: [20, 20]
    attachable.variant :thumb, resize_to_limit: [36, 36]
    attachable.variant :stats, resize_to_limit: [100, 100]
    attachable.variant :certificate, resize_to_limit: [150, 150]
  end
  has_one_attached :gold_badge do |attachable|
    attachable.variant :pictured, resize_to_limit: [20, 20]
    attachable.variant :thumb, resize_to_limit: [36, 36]
    attachable.variant :stats, resize_to_limit: [100, 100]
    attachable.variant :certificate, resize_to_limit: [150, 150]
  end

  # WSC
  def any_uploaded_wsc?
    any_uploaded?(wsc_ary)
  end

  def reset_wsc
    reset(wsc_ary)
  end

  def wsc_ary
    [wsc_1x, wsc_2x, wsc_full]
  end

  # Badges
  def any_uploaded_badge?
    any_uploaded?(badge_ary)
  end

  def reset_badges
    reset(badge_ary)
  end

  def badge_ary
    [black_badge, bronze_badge, silver_badge, gold_badge]
  end

  # Webicons
  def any_uploaded_webicon?
    any_uploaded?(webicons_ary)
  end

  def reset_webicons
    reset(webicons_ary)
  end

  def webicons_ary
    [linkedin_webicon, twitter_webicon, facebook_webicon, pinterest_webicon, youtube_webicon]
  end

  private

  def any_uploaded?(ary)
    ary.any?(&:attached?)
  end

  def reset(ary)
    ary.each(&:purge)
  end

  class << self
    def singleton
      Branding.first.nil? ? Branding.create! : Branding.first
    end
  end
end
