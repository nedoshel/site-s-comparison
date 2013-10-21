class ChangeSiteRegexpInSites < ActiveRecord::Migration
  def change
    change_column :sites, :site_regexp, :string, limit: 500
  end
end
