# frozen_string_literal: true

module Importers
  class GpgImporterService
    class << self
      def import(email, path)
        key = GPGME::Key.find(:public, email)
        return key unless key.empty?

        Rails.logger.info 'Trying to import via GPGME'
        GPGME::Key.import(File.open(path))
        key = GPGME::Key.find(:public, email)
        return key unless key.empty?

        Rails.logger.info 'Trying to import via Shell'
        sh "sudo gpg --import #{path}"
        GPGME::Key.find(:public, email)
      end
    end
  end
end
