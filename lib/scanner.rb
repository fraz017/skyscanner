class Scanner
  def self.live_price(object)
    price = {}
    index = 0 
    begin
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
          "groupPricing" => true,
          "locationschema" => "iata"
        ),
        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
      )
      if @results.headers["location"].present?
        key = @results.headers["location"].split("/").last
        @prices = Hash.new 
        @prices[:session_key] = key 
      else
        @prices = nil 
      end
      index += 1
    end while !price.present? && index <= 5
    return @prices
  end

  def self.live_price_hotel(object)
    index = 0 
    begin
      @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/hotels/liveprices/v2/#{object["market"]}/#{object["currency"]}/#{object["locale"]}/#{object["entityId"]}/#{object["checkindate"]}/#{object["checkoutdate"]}/#{object["guests"]}/#{object["rooms"]}?apiKey=#{ENV['API_KEY']}",
        :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
      )
      if @results["hotels"].present?
        key = @results.headers["location"].split("/").last
        @prices = Hash.new  
        @prices[:hotels] = @results
      else
        @prices = nil 
      end
      index += 1
    end while !@results["hotels"].present? && index <= 5
    return @prices
  end

  def self.city2country(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/#{Date.today.strftime("%Y-%m-%d")}/#{60.days.from_now.strftime("%Y-%m-%d")}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end

  def self.city2abroad(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/#{Date.today.year}/#{Date.today.year+1}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end

  def self.cityGrid(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/#{Date.today.year}/#{Date.today.year+1}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end
end    