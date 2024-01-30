# frozen_string_literal: true

class KindUtil
  KIND_ACCROS = {
    org: :organizational,
    vm: :system,
    wa: :applicative
  }.freeze

  # convert :organizational|:system|:applicative symbol into :org, :vm or :wa
  # @param **kind:** :organizational, :system or :applicative
  # @return :org, :vm or :wa
  def self.to_accro(kind)
    KIND_ACCROS.key(kind.to_sym)
  end

  # @param **accro:** vm or wa as string or symbol
  # @return :system or :applicative
  def self.from_accro(accro)
    KIND_ACCROS[accro.to_sym]
  end

  def self.accros
    KIND_ACCROS.keys
  end

  def self.scan_accros
    accros.excluding(:org)
  end

  def self.kinds
    KIND_ACCROS.values
  end
end
