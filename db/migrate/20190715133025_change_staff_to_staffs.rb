class ChangeStaffToStaffs < ActiveRecord::Migration[5.2]
  def change
    rename_table :staff, :staffs
    rename_table :staff_teams, :staffs_teams
    rename_table :staff_roles, :staffs_roles
  end
end
