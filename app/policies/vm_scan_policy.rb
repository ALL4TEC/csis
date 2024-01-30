# frozen_string_literal: true

class VmScanPolicy < ScanPolicy
  include KindConcern

  class Scope < Scope
    include KindConcern

    def list_includes
      %i[reports targets report_vm_scans]
    end
  end
end
