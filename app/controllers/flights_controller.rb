require "scanner"
require "will_paginate/array"
class FlightsController < ApplicationController
  def live_prices
    cookies.delete(:tab_1_page)
    cookies.delete(:tab_2_page)
    response = Scanner.live_price(params[:flight])
    if response.present?
      cookies[:prices_url] = response[:prices_url]
      cookies[:prices] = response[:prices]
      @prices = HTTParty.get(cookies[:prices_url])
      if @prices["Legs"].present?
        params[:page] ||=1
        set_hash
        resp = Response.where(:user_id => session.id).last
        if resp.present?
          resp.result = @cheap
          resp.prices = @prices
        else
          resp = Response.new
          resp.result = @cheap
          resp.user_id = session.id
          resp.prices = @prices
        end
        resp.save!
        @cheap = @cheap.paginate(:page => params[:page], :per_page => 10)
        @duration = @duration.paginate(:page => params[:page], :per_page => 10)
      end
    end
  end

  def refresh
    @prices = HTTParty.get(cookies[:prices_url])
    # $redis.set("price", @prices.to_json) 
    if @prices["Legs"].present?
      set_hash
    end
    params[:page] ||=1
    @cheap = @cheap.paginate(:page => params[:page].to_i, :per_page => 10)
    @duration = @duration.paginate(:page => params[:page].to_i, :per_page => 10)
    respond_to do |format|
      format.js 
    end
  end

  def custom_pagination
    resp = Response.where(:user_id => session.id).last
    @prices = resp.prices
    @cheap = resp.result
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
    @duration  = @cheap.deep_dup
    @duration = @duration.sort_by { |k| k["Duration"]}
    @tab_name = params[:tab_name]
    if params[:tab_name] == "tab_1"
      @cheap = @cheap.paginate(:page => params[:page].to_i, :per_page => 10)
      cookies[:tab_1_page] = ""
      cookies[:tab_1_page] = params[:page].to_i
      if cookies[:tab_2_page].present?
        page_no = cookies[:tab_2_page]
      else
        page_no = 1
      end
      @duration = @duration.paginate(:page => page_no.to_i, :per_page => 10)
    else
      @duration = @duration.paginate(:page => params[:page].to_i, :per_page => 10)
      cookies[:tab_2_page] = ""
      cookies[:tab_2_page] = params[:page].to_i
      if cookies[:tab_1_page].present?
        page1_no = cookies[:tab_1_page]
      else
        page1_no = 1
      end
      @cheap = @cheap.paginate(:page => page1_no.to_i, :per_page => 10)
    end
    respond_to do |format|
      format.js{
        render "refresh"
      } 
    end
  end

  private
  def set_hash
    @cheap = @prices["Legs"]
    agents = @prices["Agents"]
    places = @prices["Places"]
    segments = @prices["Segments"]
    itineraries = @prices["Itineraries"]
    carriers = @prices["Carriers"]
    currencies = @prices["Currencies"]
    empty = []
    @cheap.each_with_index do |(k, v), index|
      @cheap[index]["carrierDetail"] = []
      @cheap[index]["Carriers"].each_with_index do |c, cc|
        @cheap[index]["carrierDetail"][cc] = carriers.find { |h| h['Id'] == c }
      end
      @cheap[index]["Operators"] = []
      @cheap[index]["OperatingCarriers"].each_with_index do |c, cc|
        @cheap[index]["Operators"][cc] = carriers.find { |h| h['Id'] == c }
      end
      @cheap[index]["Segments"] = []
      @cheap[index]["SegmentIds"].each_with_index do |c, cc|
        @cheap[index]["Segments"][cc] = segments.find { |h| h['Id'] == c }
      end
      @cheap[index]["Destination"] = places.find { |h| h['Id'] == @cheap[index]["DestinationStation"] }
      @cheap[index]["Origin"] = places.find { |h| h['Id'] == @cheap[index]["OriginStation"] } 
      @cheap[index]["PriceInfo"] = []
      @cheap[index]["PriceInfo"] = itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }["PricingOptions"] if !itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }.nil?
      price = 0
      @cheap[index]["PriceInfo"].each do |p|
        price += p["Price"] 
      end
      @cheap[index]["TotalPrice"] = price.round(2)
      @cheap[index]["CurrencyCode"] = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"] 
    end
    @cheap.delete_if{ |key, value| key["TotalPrice"]==0.0 }
    params[:page] ||=1
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
    @duration  = @cheap.deep_dup
    @duration = @duration.sort_by { |k| k["Duration"]}
  end
end
