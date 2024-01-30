class AddIntroductionToReports < ActiveRecord::Migration[5.2]
  def change
  	add_column :reports, :introduction, :text
  end
end
