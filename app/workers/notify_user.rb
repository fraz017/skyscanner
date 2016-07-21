class NotifyUser
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :queue => :notify_user
  recurrence backfill: true do
  	weekly.day(:friday).hour_of_day(0).minute_of_hour(01)
  	weekly.day(:saturday).hour_of_day(0).minute_of_hour(01)
  	weekly.day(:sunday).hour_of_day(0).minute_of_hour(01)
  end


  def perform
  	UserNotification.where(active: true).each do |user|
  		if user.notification_type == "flight"
		  	begin
		  		@object = eval(user.query)
		  		@results = HTTParty.post("http://partners.api.skyscanner.net/apiservices/pricing/v1.0",
		        :body => URI.encode_www_form(
		          "apiKey" => ENV["API_KEY"],
		          "country" => @object["Country"],
		          "currency" => @object["Currency"],
		          "locale" => @object["Locale"],
		          "originplace" => @object["OriginPlace"],
		          "destinationplace" => @object["DestinationPlace"],
		          "outbounddate" => @object["OutboundDate"].present? ? Date.today.strftime("%Y-%m-%d") : Date.today.strftime("%Y-%m-%d"),
		          "inbounddate" => @object["InboundDate"].present? ? (Date.today+1).strftime("%Y-%m-%d") : "",
		          "cabinclass" => @object["CabinClass"],
		          "adults" => @object["Adults"],
		          "children" => @object["Children"],
		          "infants" => @object["Infants"],
		          "groupPricing" => true
		        ),
		        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
		      )
		      if @results.headers["location"].present?
		        @key = @results.headers["location"].split("/").last
		        @prices = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
		      end	      
		    end while !@prices.present?
		    begin
		    	sleep(2)
	        @prices = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
	      end while @prices["Status"] != "UpdatesComplete"
		    set_hash
		    if user.price > @cheap[0]["TotalPrice"]
			    Notifier.notify_user(user, @cheap.first(10)).deliver_now
			  end
			else
				begin
					date = Date.today
					checkindate = date.strftime("%F")
					checkoutdate = (date + 1.week).strftime("%F")
					@object = eval(user.query)
					index = 0 
			    begin
			      @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/hotels/liveprices/v2/#{@object[:market]}/#{@object[:currency]}/#{@object[:locale]}/#{@object[:entityId]}/#{checkindate}/#{checkoutdate}/#{@object[:guests]}/#{@object[:rooms]}?apiKey=#{ENV['API_KEY']}",
			        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
			      )
			    end while !@results["hotels_prices"].present? && index <= 5
			    if @results["hotels_prices"].present?
			    	results =  @results["hotels_prices"].select{|s| s["agent_prices"].map{|d| d["price_total"]}.first }
			    	ids = results.map{|s| s["id"]}.join(",")
            response = HTTParty.get(ENV['HOTEL_POLLING_URL']+URI.decode(@results["urls"]["hotel_details"])+"&hotelIds="+ids)
			    	if response.present?
              @prices = JSON.parse(response)
              set_hotel_hash
              @currency = @object[:currency]
  			    	Notifier.notify_user_hotels(user, @hotels, @currency).deliver_now
            end
			    end
			  rescue
			  	''
			  end
			end  
  	end
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
          cheap[k]["CurrencyCode"] = currencies.find { |h| h['Code'] == @object['Currency']}["Symbol"]
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
end