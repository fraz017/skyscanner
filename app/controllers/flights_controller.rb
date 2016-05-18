require "scanner"
class FlightsController < ApplicationController
  def live_prices
    response = Scanner.live_price(params[:flight])
    cookies[:prices_url] = response[:prices_url]
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

  # def cities
  #   @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",cookies[:country], cookies[:currency])
  #   @country = "Top Locations in Your Country"
  #   @countryCode = cookies[:country].downcase
  #   set_grid
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # def usa
  #   @places = Scanner.city2country("US","US", cookies[:currency])
  #   @country = "Top Locations in USA"
  #   @countryCode = "us"
  #   set_grid
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # def asia
  #   @places = Scanner.city2country("AE","AE", cookies[:currency])
  #   @country = "Top Locations in Asia & Middle East"
  #   @countryCode = "ae"
  #   set_grid
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # def africa
  #   @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong","CE", cookies[:currency])
  #   @country = "Top Locations in Africa"
  #   @countryCode = "ce"
  #   set_grid
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  # def europe
  #   @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",cookies[:country], cookies[:currency])
  #   @country = "Top Locations in Europe"
  #   @countryCode = cookies[:country].downcase
  #   set_grid
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  def grid
    @grids = Scanner.cityGrid("#{cookies[:latitude]},#{cookies[:longitude]}-latlong", params[:destination], cookies[:country], cookies[:currency])
    respond_to do |format|
      format.js
    end
  end

  private
  def set_hash
    legs = @prices["Legs"]
    agents = @prices["Agents"]
    places = @prices["Places"]
    segments = @prices["Segments"]
    itineraries = @prices["Itineraries"]
    carriers = @prices["Carriers"]
    currencies = @prices["Currencies"]
    stops = @prices["Stops"]
    @cheap = Array.new
    itineraries.each do |it|
      empty = Hash.new
      empty["outbound"] = legs.find { |h| h['Id'] == it["OutboundLegId"] } if it["OutboundLegId"].present?
      empty["inbound"] = legs.find { |h| h['Id'] == it["InboundLegId"] } if it["InboundLegId"].present?
      empty["PriceInfo"] = it["PricingOptions"]
      empty["PriceInfo"] = empty["PriceInfo"].sort_by { |k| k["Price"] }
      empty["TotalPrice"] = 0.0
      empty["TotalPrice"] = empty["PriceInfo"][0]["Price"] if empty["PriceInfo"].present? 
      empty["Duration"] = empty["outbound"]["Duration"]
      @cheap.push(empty)
    end
    @cheap.each do |cheap|
      cheap.each_with_index do |(k, v), index|
        if k == "outbound" || k == "inbound"
          cheap[k]["carrierDetail"] = []
          cheap[k]["Carriers"].each_with_index do |c, cc|
            cheap[k]["carrierDetail"][cc] = carriers.find { |h| h['Id'] == c }
          end
          cheap[k]["Operators"] = []
          cheap[k]["OperatingCarriers"].each_with_index do |c, cc|
            cheap[k]["Operators"][cc] = carriers.find { |h| h['Id'] == c }
          end
          cheap[k]["Segments"] = []
          cheap[k]["SegmentIds"].each_with_index do |c, cc|
            cheap[k]["Segments"][cc] = segments.find { |h| h['Id'] == c }
          end
          cheap[k]["StopPlaces"] = []
          cheap[k]["Stops"].each_with_index do |c, cc|
            cheap[k]["StopPlaces"][cc] = places.find { |h| h['Id'] == c } if !places.find { |h| h['Id'] == c }.nil?
          end
          cheap[k]["Destination"] = places.find { |h| h['Id'] == cheap[k]["DestinationStation"] }
          cheap[k]["Origin"] = places.find { |h| h['Id'] == cheap[k]["OriginStation"] } 
          cheap[k]["CurrencyCode"] = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"]
        end   
      end
    end
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
    @duration  = @cheap.deep_dup
    @duration = @duration.sort_by { |k| k["Duration"]}
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
