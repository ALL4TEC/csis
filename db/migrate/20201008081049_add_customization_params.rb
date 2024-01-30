class AddCustomizationParams < ActiveRecord::Migration[6.0]
  def change
    create_table :customizations, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :key, nil: false
      t.string :value, nil: false
    end
    add_index :customizations, :key, unique: true
  end
end
