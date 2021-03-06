require "scanner"
class FlightsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:live_prices, :live_prices_hotels]
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
      format.html
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

  def live_prices_hotels
    begin 
      response = Scanner.live_price_hotel(params)
      @prices = response[:hotels]
      cookies[:session_key] = @prices["urls"]["hotel_details"]
      cookies[:hotel_ids] = @hotel_ids 
    rescue
    end  
    if @prices.present?
      set_hotel_hash
    end
    respond_to do |format|
      # format.js { render "refresh_hotels"}
      format.html
    end
  end

  def refresh_hotels
    begin
      response = HTTParty.get(ENV['HOTEL_POLLING_URL']+URI.decode(cookies[:session_key])+"&hotelIds="+cookies[:hotel_ids])
      @prices = JSON.parse(response)
    rescue
    end  
    if @prices.present?
      set_hotel_hash
    end
    @status = @prices["status"]
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
    @places = Scanner.cityGrid("#{cookies[:latitude]},#{cookies[:longitude]}-latlong", params[:iata].upcase, cookies[:country], cookies[:currency])
    set_grid
    respond_to do |format|
      format.html
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

  def getaways
  end

  private
  def set_hash
    legs = Array.new
    legs = @prices["Legs"]
    agents = Array.new
    agents = @prices["Agents"]
    places = Array.new
    places = @prices["Places"]
    segments = Array.new
    segments = @prices["Segments"]
    itineraries = Array.new
    itineraries = @prices["Itineraries"]
    carriers = Array.new
    carriers = @prices["Carriers"]
    currencies = Array.new
    currencies = @prices["Currencies"]
    stops = Array.new
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

  def set_hotel_hash
    @hotels = Array.new 
    hotel_prices = @prices["hotels_prices"]
    hotels = @prices["hotels"]
    agents = @prices["agents"]
    amenities = @prices["amenities"]
    @hotel_ids = hotels.map{|s| s["hotel_id"]}.map{|s| s}.join(',')
    cookies[:hotel_ids] = @hotel_ids
    @status = "First"
    hotel_prices.each do |hotel|
      amen = Array.new
      agnts = Array.new
      hotel_images = Array.new
      hot = Hash.new
      count = 0
      hot["hotel"] = hotels.select { |s| s["hotel_id"] == hotel["id"] }.first
      hotel["agent_prices"].each_with_index do |ag, index|
        agnts[index] = agents.select { |s| s["id"] == ag["id"] }.first.merge(ag) 
      end
      hot["hotel"]["images"].each do |k,v|
        if k.present? 
          hot["hotel"]["images"][k].keys.each do |img|
            if img == "morig.jpg"
              hotel_images[count] = "http://"+@prices["image_host_url"]+k+img
              count += 1
            end
          end
        end
      end
      hot["agents"] = agnts
      hot["images"] = hotel_images
      hot["ratings"] = hotel["ratings"]
      hot["guests"] = hotel["guests"]
      hot["reviews_count"] = hotel["reviews_count"]
      hot["hotel"]["amenities"].each_with_index do |am,index|
        amen[index] = amenities.select { |s| s["id"] == am }.first 
      end
      hot["amenities"] = amen
      @hotels.push(hot)
    end 
    @star_rating_asc = @hotels.sort_by {|a| a["hotel"]["star_rating"] } if @hotels[0]["hotel"]["star_rating"].present?
    @star_rating_desc = @star_rating_asc.reverse if @star_rating_asc.present?
    @hotels.map{|s| s["hotel"]["popularity"] = 0 if s["hotel"]["popularity"].nil? }
    @guests_ratings = @hotels.sort_by {|a| a["hotel"]["popularity"]}
    @p_low_to_high = @hotels.sort_by {|a| a["agents"].map{|s| s["price_total"]} }
    @p_high_to_low = @p_low_to_high.reverse
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
      q["CName"] = carriers.find{ |p| p["CarrierId"] == q["OutboundLeg"]["CarrierIds"][0]}
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
    params.require(:user_notification).permit(:email, :name, :price, :query, :notification_type)
  end
end
