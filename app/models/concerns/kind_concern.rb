# frozen_string_literal: true

module KindConcern
  extend ActiveSupport::Concern

  included do |base|
    if base.name[0, 2].downcase.to_sym.in?(KindUtil.scan_accros)
      def self.kind_accro
        name[0, 2].downcase
      end

      def self.kind
        KindUtil.from_accro(name[0, 2].downcase.to_sym)
      end

      # @return **the kind acronyme of the instanciated object** 'vm' or 'wa'
      def kind_accro
        self.class.name[0, 2].downcase
      end

      # @return **the kind of the instanciated object** :system or :applicative
      def kind
        KindUtil.from_accro(self.class.name[0, 2].downcase.to_sym)
      end

      def vm?
        kind_accro == :vm
      end

      def wa?
        kind_accro == :wa
      end
    end
  end
end
