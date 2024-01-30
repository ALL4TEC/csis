# frozen_string_literal: true

class Certificate < ApplicationRecord
  include EnumSelect
  has_paper_trail

  CUSTOMIZABLE_FIELDS = %w[basic_text title_text highlighted_text informative_text signatory_title
                           signatory_name signatory_town].freeze
  IMG_ALT = 'WSC'

  after_create do
    update_certificate
  end

  belongs_to :project,
    class_name: 'Project',
    primary_key: :id,
    inverse_of: :certificate

  has_many :certificates_languages,
    class_name: 'CertificateLanguage',
    inverse_of: :certificate,
    dependent: :delete_all

  has_many :languages,
    class_name: 'Language',
    foreign_key: :language_id,
    inverse_of: :certificates,
    through: :certificates_languages

  enum_with_select :transparency_level, { secretive: 0, obfuscate: 1, clearness: 2 }

  # Update certificate picture in CSIS when modifying in the statistics
  # of the project with the dropdown list
  def update_certificate
    update(path: 'WSC_1x.png')
    project.make_folder
    clean_folder
    languages.each do |lang|
      Generators::CertificateGeneratorJob.perform_later(project, lang.iso)
      create_link(lang)
    end
  end

  # Create the link that the client will copy on his website to synchronize with his
  # client account in the CSIS
  def create_link(lang)
    name = project.fname('dir')
    file = "#{project.fname('file')}-#{lang.iso}"
    file_path = File.join(ENV.fetch('ROOT_URL'), 'WSC', name, file)
    image_file_path = File.join(ENV.fetch('ROOT_URL'), 'WSC', name, project.fname('file'))

    l = "<a target='popup' href='#{file_path}.pdf'>" \
        "<img src='#{image_file_path}.png' " \
        "srcset='#{image_file_path}.png 1x,#{image_file_path}_2.png 2x' " \
        "alt='#{IMG_ALT}'></a>"

    certificates_languages.where(language_id: lang.id).update(sync_link: l)
  end

  # Remove PDF before update new
  def clean_folder
    path = Rails.public_path.join('WSC', project.fname('dir'), "#{project.fname('file')}*.pdf")
    FileUtils.rm Dir.glob(path)
  end
end
