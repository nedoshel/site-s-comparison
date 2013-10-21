class ChangeSiteContextSites < ActiveRecord::Migration
  def change
    change_column :sites, :site_context, :mediumtext
    change_column :sites, :old_site_context, :mediumtext
  end
end
