class NotifyUser
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :queue => :notify_user
  recurrence backfill: true do
    daily.hour_of_day(0).minute_of_hour(00)
  end


  def perform
  	UserNotification.all.each do |user|
	  	begin
	  		object = eval(user.query)
	  		@results = HTTParty.post("http://partners.api.skyscanner.net/apiservices/pricing/v1.0",
	        :body => URI.encode_www_form(
	          "apiKey" => ENV["API_KEY"],
	          "country" => object["Country"],
	          "currency" => object["Currency"],
	          "locale" => object["Locale"],
	          "originplace" => object["OriginPlace"],
	          "destinationplace" => object["DestinationPlace"],
	          "outbounddate" => object["OutboundDate"].present? ? Date.today.strftime("%Y-%m-%d") : "",
	          "inbounddate" => object["InboundDate"].present? ? (Date.today+1).strftime("%Y-%m-%d") : "",
	          "cabinclass" => object["CabinClass"],
	          "adults" => object["Adults"],
	          "children" => object["Children"],
	          "infants" => object["Infants"],
	          "groupPricing" => true
	        ),
	        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
	      )
	      if @results.headers["location"].present?
	        @key = @results.headers["location"].split("/").last
	        @price = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
	      end	      
	    end while !@price.present?
	    begin
	    	sleep(2)
        @price = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
      end while @price["Status"] != "UpdatesComplete"
	    legs = @price["Legs"]
	    places = @price["Places"]
	    itineraries = @price["Itineraries"]
	    currencies = @price["Currencies"]
	   	@cheap = Array.new
	    itineraries.each do |it|
	      empty = Hash.new
	      empty["outbound"] = legs.find { |h| h['Id'] == it["OutboundLegId"] } if it["OutboundLegId"].present?
	      empty["inbound"] = legs.find { |h| h['Id'] == it["InboundLegId"] } if it["InboundLegId"].present?
	      empty["PriceInfo"] = it["PricingOptions"]
	      empty["PriceInfo"] = empty["PriceInfo"].sort_by { |k| k["Price"] }
	      empty["TotalPrice"] = 0.0
	      empty["TotalPrice"] = empty["PriceInfo"][0]["Price"] if empty["PriceInfo"].present? 
	      @cheap.push(empty)
	    end
	    @cheap.each do |cheap|
	      cheap.each_with_index do |(k, v), index|
	        if k == "outbound" || k == "inbound"
	          cheap[k]["Destination"] = places.find { |h| h['Id'] == cheap[k]["DestinationStation"] }
	          cheap[k]["Origin"] = places.find { |h| h['Id'] == cheap[k]["OriginStation"] } 
	          cheap[k]["CurrencyCode"] = currencies.find { |h| h['Code'] == object['Currency']}["Symbol"]
	        end   
	      end
	    end
	    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
	    if user.price > @cheap[0]["TotalPrice"]
		    Notifier.notify_user(user, @cheap[0]).deliver_now
		  end
  	end
  end
end