# -*- coding: utf-8 -*-
class SitesController < ApplicationController
  def index
    @sites = Site.paginate  page: params[:page], order: 'site_updated_at desc', limit: 20
  end

  def new
    @site = Site.new
  end

def create
    @site = Site.new(params[:site])
    if @site.save
      respond_to do |format|
        flash[:notice] = t("msg.saved")
        format.html {redirect_to edit_site_path(@site)} 
      end
    else
      @errors = @site.errors.full_messages
      flash[:error] = t("msg.save_error")
      render :new
    end
  end
  
  def edit
    @site = Site.find(params[:id])
  end
  
  def update
    @site = Site.find(params[:id])
    if @site.update_attributes(params[:site])
      respond_to do |format|
        flash[:notice] = t("msg.saved")
        format.html {redirect_to edit_site_path(@site)}
      end
    else
      @errors = @site.errors.full_messages
      flash[:error] = t("msg.save_error")
      render :edit
    end
  end
  
  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    respond_to do |format|
      flash[:notice] = t("msg.deleted")
      format.html {redirect_to sites_path}
    end
  end

  def update_time
    site = Site.find(params[:id])    
    respond_to do |format|
      res = site.compare_context
      if res[:status] == 'ok'
        unless res[:flag]
          flash[:notice] = t("msg.updated")
        else
          flash[:notice] = t("msg.not_updated")
        end
      else
        flash[:error] = res[:status]
      end
      format.html {redirect_to sites_path}
    end  
  end
end