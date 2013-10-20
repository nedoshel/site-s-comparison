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
    reg = Regexp.new(site_regexp.split(/\r\n/).join("|"))
    # old = sanitize(self.old_site_context.to_s, tags: %w(), attributes: %w())
    #   .strip.gsub(/\s+|\!--.+--\>/, ' ')
    # current = sanitize(self.site_context.to_s, tags: %w(), attributes: %w())
    #   .strip.gsub(/\s+|\!--.+--\>/, ' ')
    old = self.old_site_context.to_s
      # .strip.gsub(/\s+|\!--.+--\>/, ' ')
    current = self.site_context.to_s
      # .strip.gsub(/\s+|\!--.+--\>/, ' ')
    [current.gsub(reg, ''), old.gsub(reg, '')]
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
      self.site_context = new_context = open(site_url).read
    #rescue => e
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
