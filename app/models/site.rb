# -*- coding: utf-8 -*-
class Site < ActiveRecord::Base
  require 'open-uri'
  attr_accessible :site_context,
                  :site_updated_at,
                  :site_url,
                  :site_regexp

  validates :site_url, uniqueness: true
  before_create :set_site_updated_at

  class << self
    def update_sites
      self.all.each do |site|
        site.compare_context
      end
    end
  end

  # сравнить содержимое
  def compare_context
    old_site_content = site_context
    begin
      self.site_context = new_site_content = open(site_url).read
    #rescue => e
    rescue
      return {status: 'error while connecting', flag: false}
    end
    if self.site_regexp.present?       
      reg = Regexp.new(self.site_regexp)
      old_site_content = old_site_content.gsub(reg, '')
      new_site_content = new_site_content.gsub(reg, '')
    end   
    if old_site_content == new_site_content
      return {status: 'ok', flag: true} 
    else 
      self.site_updated_at = Time.now
      self.save
      return {status: 'ok', flag: false}
    end
  end

  private

  def set_site_updated_at
    set_site_updated_at = Time.now
  end
   
end
