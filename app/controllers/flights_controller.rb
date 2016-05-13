require "scanner"
class FlightsController < ApplicationController
  def live_prices
    response = Scanner.live_price(params[:flight])
    cookies[:prices_url] = response[:prices_url]
    cookies[:prices] = response[:prices]
    @prices = HTTParty.get(cookies[:prices_url])
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js { render "refresh"}
    end
  end

  def refresh
    @prices = HTTParty.get(cookies[:prices_url])
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js 
    end
  end

  def cities
    @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",cookies[:country], cookies[:currency])
    @country = "Top Locations in Your Country"
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def usa
    @places = Scanner.city2country("US","US", cookies[:currency])
    @country = "Top Locations in USA"
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def asia
    @places = Scanner.city2country("AE","AE", cookies[:currency])
    @country = "Top Locations in Asia & Middle East"
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def africa
    @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong","CE", cookies[:currency])
    @country = "Top Locations in Africa"
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def europe
    @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",cookies[:country], cookies[:currency])
    @country = "Top Locations in Europe"
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def grid
    @grids = Scanner.cityGrid("#{cookies[:latitude]},#{cookies[:longitude]}-latlong", params[:destination], cookies[:country], cookies[:currency])
    respond_to do |format|
      format.js
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
    # $redis.set("prices", @prices.to_json)
    # $redis.set("cheap", @cheap.to_json)
    # $redis.set("duration", @duration.to_json)
  end

  def set_grid
    carriers = @places["Carriers"]
    currencies = @places["Currencies"]
    places = @places["Places"]
    @locations = []
    @locations = @places["Quotes"] if !@places["Quotes"].nil?
    @locations.each do |q|
      q["Destination"] = places.find{ |p| p["PlaceId"] == q["OutboundLeg"]["DestinationId"]}
    end
    if @locations.present?
      @symbol = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"]
      @locations.delete_if{ |key, value| key["MinPrice"]==0.0 }
      @locations = @locations.sort_by { |k| k["MinPrice"]}
    end
  end
end
