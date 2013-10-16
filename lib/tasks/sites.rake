# -*- coding: utf-8 -*-
namespace :sites do
  task update: :environment do
    Site.update_sites
  end
end