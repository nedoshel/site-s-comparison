# -*- coding: utf-8 -*-
class Site < ActiveRecord::Base
  require 'open-uri'
  attr_accessible :site_context,
                  :old_site_context,
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

  # Список регулярных выражений
  def regexp
    site_regexp.split(/\r\n/)
  end

  # Разница
  def diff
    old = self.old_site_context.to_s.gsub(/\r?\n?\t/, '')
    current = self.site_context.to_s.gsub(/\r?\n?\t/, '')
    if self.site_regexp.present?
      regexp.each do |r|  
        reg = Regexp.new(r)          
        old = old.gsub(reg, '')
        current = current.gsub(reg, '')
      end    
    end
    Diffy::Diff.new(current, old, allow_empty_diff: false).to_s(:html)
  end

  # сравнить содержимое
  def compare_context
    self.old_site_context = old_context = self.site_context
    begin
      self.site_context = new_context = open(site_url).read
    #rescue => e
    rescue
      return {status: 'error while connecting', flag: false}
    end
    if self.site_regexp.present?       
      regexp.each do |r|  
        reg = Regexp.new(r) 
        old_context = old_context.gsub(reg, '')
        new_context = new_context.gsub(reg, '')
      end
    end
    if old_context == new_context
      self.save
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
