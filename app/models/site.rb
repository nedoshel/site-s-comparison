# -*- coding: utf-8 -*-
class Site < ActiveRecord::Base
  require 'open-uri'
  include ActionView::Helpers::SanitizeHelper

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

  # ВОзвращает старое и новое site_context,
  # применяя регулярные выражения
  def regexp!
    old = self.old_site_context.to_s
    current = self.site_context.to_s
    if site_regexp.present?
      reg = Regexp.new(site_regexp.split(/\r\n/).join("|"), Regexp::MULTILINE)
      [current.gsub(reg, ''), old.gsub(reg, '')]
    else
      [current, old]
    end
  end

  # Разница
  def diff
    current, old = regexp!
    Diffy::Diff.new(current, old, allow_empty_diff: false).to_s(:html)
  end

  # сравнить содержимое
  def compare_context
    self.old_site_context = old_context = self.site_context.to_s

    begin
      Timeout::timeout(10){ 
       self.site_context = new_context = open(site_url, { read_timeout: 10 }).read
      }       
      #self.site_context = new_context = %x(wget -qO- #{site_url} | cat)
    rescue Timeout::Error
      return {status: 'timeout', flag: false}
    rescue
      return {status: 'error while connecting', flag: false}
    end
    if self.site_regexp.present?       
      new_context, old_context = regexp!
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
