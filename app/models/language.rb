# frozen_string_literal: true

class Language < ApplicationRecord
  has_paper_trail

  has_many :certificates_languages,
    class_name: 'CertificateLanguage',
    inverse_of: :language,
    dependent: :delete_all

  has_many :certificates,
    class_name: 'Certificate',
    foreign_key: :certificate_id,
    inverse_of: :languages,
    through: :certificates_languages

  has_many :reports,
    class_name: 'Report',
    inverse_of: :language,
    primary_key: :id,
    dependent: :nullify

  has_many :projects,
    class_name: 'Project',
    inverse_of: :language,
    primary_key: :id,
    dependent: :nullify

  has_many :users,
    class_name: 'User',
    inverse_of: :language,
    primary_key: :id,
    dependent: :nullify

  def to_s
    iso
  end
end
