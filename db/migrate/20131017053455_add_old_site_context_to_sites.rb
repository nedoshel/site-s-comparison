# -*- coding: utf-8 -*-
class AddOldSiteContextToSites < ActiveRecord::Migration
  def change
  	add_column :sites, :old_site_context, :text, after: :site_context
  end
end
