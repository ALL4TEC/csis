class AddBranding < ActiveRecord::Migration[7.0]
  def change
    create_table :brandings, id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
      t.string :company_url
      t.string :linkedin_url
      t.string :twitter_url
      t.string :facebook_url
      t.string :pinterest_url
      t.string :youtube_url
      t.timestamps
    end

    Branding.create!()
  end
end
