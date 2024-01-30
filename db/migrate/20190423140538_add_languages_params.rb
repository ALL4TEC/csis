class AddLanguagesParams < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :language, :string, default: 'fr'
    add_column :staff, :language, :string, default: 'fr'
    add_column :reports, :language, :string, default: 'fr'
    add_column :projects, :language, :string, default: 'fr'
  end
end
