class NotifyUser
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options :queue => :notify_user
  recurrence backfill: true do
    daily.hour_of_day(0).minute_of_hour(00)
  end


  def perform
  	UserNotification.each do |user|
	  	begin
	  		object = eval(user.query)
	  		@results = HTTParty.post("http://partners.api.skyscanner.net/apiservices/pricing/v1.0",
	        :body => URI.encode_www_form(
	          "apiKey" => ENV["API_KEY"],
	          "country" => object["country"],
	          "currency" => object["currency"],
	          "locale" => object["locale"],
	          "originplace" => object["originplace"]+"-sky",
	          "destinationplace" => object["destinationplace"]+"-sky",
	          "outbounddate" => object["outbounddate"],
	          "inbounddate" => object["inbounddate"],
	          "cabinclass" => object["cabinclass"],
	          "adults" => object["adults"],
	          "children" => object["children"],
	          "infants" => object["infants"],
	          "groupPricing" => true
	        ),
	        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
	      )
	      if @results.headers["location"].present?
	        @key = @results.headers["location"].split("/").last
	        @price = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
	      end
	    end while !price.present?

	    begin
        @price = HTTParty.get(ENV['POLLING_URL']+@key+"?apiKey=#{ENV['API_KEY']}")
      end while price["Status"] != "UpdateComplete"

      itineraries = @prices["Itineraries"]
	    @cheap = Array.new
	    itineraries.each do |it|
	      empty = Hash.new
	      empty["PriceInfo"] = it["PricingOptions"]
	      empty["PriceInfo"] = empty["PriceInfo"].sort_by { |k| k["Price"] }
	      empty["TotalPrice"] = 0.0
	      empty["TotalPrice"] = empty["PriceInfo"][0]["Price"] if empty["PriceInfo"].present? 
	      @cheap.push(empty)
	    end
	    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
	    Notifier.notify_user(user, @cheap[0])
  	end
  end
end