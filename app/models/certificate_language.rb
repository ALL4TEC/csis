# frozen_string_literal: true

class CertificateLanguage < ApplicationRecord
  self.table_name = :certificates_languages

  belongs_to :certificate,
    class_name: 'Certificate',
    inverse_of: :certificates_languages,
    primary_key: :id

  belongs_to :language,
    class_name: 'Language',
    inverse_of: :certificates_languages,
    primary_key: :id
end
