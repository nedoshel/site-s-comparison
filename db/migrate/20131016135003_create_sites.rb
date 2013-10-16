class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :site_url
      t.text :site_context
      t.datetime :site_updated_at
      t.string :site_regexp
      t.timestamps
    end
  end
end
