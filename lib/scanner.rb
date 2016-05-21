class Scanner
  def self.live_price(object)
    price = {}
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
        price = HTTParty.get(ENV['POLLING_URL']+key+"?apiKey=#{ENV['API_KEY']}")
        @prices = Hash.new 
        @prices[:session_key] = key  
        @prices[:prices] = price
      else
        @prices = nil 
      end
    end while !price.present? || price["Legs"].count == 0
    return @prices
  end

  def self.city2country(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/#{Date.today.strftime("%Y-%m")}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end

  def self.city2abroad(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/2016/2017?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end

  def self.cityGrid(city, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{destination}/2016/2017?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end
end    