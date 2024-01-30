class CreateVulnerabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :vulnerabilities, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :qid, null: false
      t.text :cve_id, array: true, default: []
      t.string :title, null: false
      t.string :category, null: false
      t.string :sub_category
      t.string :vendor_reference
      t.decimal :cvss_base
      t.decimal :cvss3_base
      t.string :bugtraq_id
      t.string :severity
      t.text :description_fr
      t.text :solution_fr
      
      t.datetime :modified, null: false
      t.datetime :published, null: false
      t.timestamps
    end

    add_index :vulnerabilities, :qid, unique: true 
  end
end
