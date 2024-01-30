class MoveFollowTypeToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :follow_type, :integer, default: 0, null: false

    #TODO gérer le déplacement du follow_type
    Project.all.each do |p|
      if p.certificate.follow_type = 2
        p.reports.update_all(follow_type: 1)
      else
        p.reports.update_all(follow_type: 0)
      end
    end

    remove_column :certificates, :follow_type, :integer

    add_column :reports, :scoring_vm_aggregate, :integer, default: 0
    add_column :reports, :scoring_was_aggregate, :integer, default: 0
    add_column :statistics, :number_of_pentests, :integer, default: 0
  end
end
