require "scanner"
class FlightsController < ApplicationController
  def live_prices
    response = Scanner.live_price(params[:flight])
    cookies[:session_key] = response[:session_key]
    @prices = {}
    index = 0
    begin
      @prices = HTTParty.get(ENV['POLLING_URL']+cookies[:session_key]+"?apiKey=#{ENV['API_KEY']}")
      index += 1
    end while !@prices.present? && index <= 5 
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js { render "refresh"}
    end
  end

  def refresh
    @prices = HTTParty.get(ENV['POLLING_URL']+cookies[:session_key]+"?apiKey=#{ENV['API_KEY']}")
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js 
    end
  end

  def cities
    @places = Scanner.city2country("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",cookies[:country], cookies[:country], cookies[:currency])
    @country = "Top Locations in Your Country"
    @countryCode = cookies[:countryCode].downcase
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def nigeria
    cities = ["CBQA", "LOSA", "ABVA", "PHCA", "ENUA", "OWEB", "KANA", "KADA", "IBAA", "UYOA", "SKOA", "JOSA"]
    @places = Array.new
    cities.each do |city|
      place = Scanner.city2abroad("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",city, cookies[:country], cookies[:currency])
      place['code'] = city.downcase
      @places.push(place)
    end
    @country = "Top Locations in Nigeria"
    @countryCode = "ce"
    set_grid2
    respond_to do |format|
      format.js
    end
  end

  def usa
    cities = ["WASA", "NYCA", "RIOA", "SAOA", "HOUA", "LASA", "LAXA", "CHIA", "YVRA", "YTOA"]
    @places = Array.new
    cities.each do |city|
      place = Scanner.city2abroad("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",city, cookies[:country], cookies[:currency])
      place['code'] = city.downcase
      @places.push(place)
    end
    @country = "Top Locations in USA"
    @countryCode = "us"
    set_grid2
    respond_to do |format|
      format.js
    end
  end

  def asia
    cities = ["DXBA", "SINS", "DOHA", "HKGA", "BKKT", "TYOA", "KULM", "AUHA", "TELA", "JEDA"]
    @places = Array.new
    cities.each do |city|
      place = Scanner.city2abroad("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",city, cookies[:country], cookies[:currency])
      place['code'] = city.downcase
      @places.push(place)
    end
    @country = "Top Locations in Asia & Middle East"
    @countryCode = "ae"
    set_grid2
    respond_to do |format|
      format.js
    end
  end

  def africa
    cities = ["ZNZA", "HREA", "CPTA", "JNBA", "NBOA", "MRUA"]
    @places = Array.new
    cities.each do |city|
      place = Scanner.city2abroad("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",city, cookies[:country], cookies[:currency])
      place['code'] = city.downcase
      @places.push(place)
    end
    @country = "Top Locations in Africa"
    @countryCode = "ce"
    set_grid2
    respond_to do |format|
      format.js
    end
  end

  def europe
    cities = ["LOND", "ISTA", "PARI", "ROME", "FLOR", "MILA", "VENI", "BARC", "MADR", "AMST", "DUBL", "VIEN"]
    @places = Array.new
    cities.each do |city|
      place = Scanner.city2abroad("#{cookies[:latitude]},#{cookies[:longitude]}-latlong",city, cookies[:country], cookies[:currency])
      place['code'] = city.downcase
      @places.push(place)
    end
    @country = "Top Locations in Europe"
    @countryCode = cookies[:country].downcase
    set_grid2
    respond_to do |format|
      format.js
    end
  end

  def grid
    @places = Scanner.cityGrid("#{cookies[:latitude]},#{cookies[:longitude]}-latlong", params[:destination], cookies[:country], cookies[:currency])
    set_grid
    respond_to do |format|
      format.js
    end
  end

  def watchdog
    @notification = UserNotification.new(notify_params)
    @prices = Hash.new
    @prices["Query"] = params[:user_notification][:query]
    if @notification.save
      @success = true
    end
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
      empty["PriceInfo"].each do |obj|
        obj["AgentDetail"] = agents.find { |h| h['Id'] == obj["Agents"][0] } if obj["Agents"][0].present?  
      end
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
      q["Origin"] = places.find{ |p| p["PlaceId"] == q["OutboundLeg"]["OriginId"]}
      q["Currencies"] = currencies
      q["Departure"] = DateTime.parse(q["OutboundLeg"]["DepartureDate"])
    end
    if @locations.present?
      @symbol = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"]
      @locations.delete_if{ |key, value| key["MinPrice"]==0.0 }
      @locations = @locations.sort_by { |k| k["Departure"]}
    end
  end

  def set_grid2
    @locations = Array.new
    @places.each do |place|
      carriers = place["Carriers"]
      currencies = place["Currencies"]
      places = place["Places"]
      location = []
      location = place["Quotes"] if !place["Quotes"].nil?
      location.each do |q|
        q["Destination"] = places.find{ |p| p["PlaceId"] == q["OutboundLeg"]["DestinationId"]}
      end
      if location.present?
        @symbol = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"]
        location.delete_if{ |key, value| key["MinPrice"]==0.0 }
        location = location.sort_by { |k| k["MinPrice"]}
        @locations.push(location)
      end
    end   
  end

  private

  def notify_params
    params.require(:user_notification).permit(:email, :name, :price, :query)
  end
end
