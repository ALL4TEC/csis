# frozen_string_literal: true

class WaScanPolicy < ScanPolicy
  include KindConcern

  class Scope < Scope
    include KindConcern

    def list_includes
      %i[reports report_wa_scans]
    end
  end
end
