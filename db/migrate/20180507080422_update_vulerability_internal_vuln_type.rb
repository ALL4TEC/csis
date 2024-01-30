class UpdateVulerabilityInternalVulnType < ActiveRecord::Migration[5.2]
  def change
    rename_column :vulnerabilities, :vuln_type, :internal_type
    add_column :vulnerabilities, :vuln_type, :string
  end
end
