require "scanner"
require "will_paginate/array"
class FlightsController < ApplicationController
  def live_prices
    # cookies.delete(:tab_1_page)
    # cookies.delete(:tab_2_page)
    response = Scanner.live_price(params[:flight])
    cookies[:prices_url] = response[:prices_url]
    cookies[:prices] = response[:prices]
    @prices = HTTParty.get(cookies[:prices_url])
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js { render "refresh", :locals => {:prices => @prices, :cheap => @cheap, :duration => @duration} }
    end
  end

  def test 
    @prices = JSON.parse($redis.get("prices")) 
    @cheap = JSON.parse($redis.get("cheap"))
    @duration = JSON.parse($redis.get("duration"))  
    render template: "flights/live_prices"
  end

  def refresh
    @prices = HTTParty.get(cookies[:prices_url])
    # $redis.set("price", @prices.to_json) 
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js { render "refresh", :locals => {:prices => @prices, :cheap => @cheap, :duration => @duration} }
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
    stops = @prices["Stops"]
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
      @cheap[index]["StopPlaces"] = []
      @cheap[index]["Stops"].each_with_index do |c, cc|
        @cheap[index]["StopPlaces"][cc] = places.find { |h| h['Id'] == c } if !places.find { |h| h['Id'] == c }.nil?
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
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
    @duration  = @cheap.deep_dup
    @duration = @duration.sort_by { |k| k["Duration"]}
    $redis.set("prices", @prices.to_json)
    $redis.set("cheap", @cheap.to_json)
    $redis.set("duration", @duration.to_json)
  end
end
