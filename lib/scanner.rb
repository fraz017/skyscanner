class Scanner
  def self.live_price(object)
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
        "locationschema" => "Sky"
      ),
      :headers => { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' }
    )
    if @results.headers["location"].present?
      price = HTTParty.get(@results.headers["location"]+"?apiKey=#{ENV['API_KEY']}")
      @prices = Hash.new 
      @prices[:prices_url] = @results.headers["location"]+"?apiKey=#{ENV['API_KEY']}"  
      @prices[:prices] = price
    else
      @prices = nil
    end
    return @prices
  end

  def self.city2country(city, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/#{country}/#{currency}/en-US/#{city}/#{country}/#{Date.today.strftime("%Y-%m-%d")}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end

  def self.cityGrid(origin, destination, country, currency)
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/browsegrid/v1.0/#{country}/#{currency}/en-US/#{origin}/#{destination}/#{Date.today.next_month.strftime("%Y-%m")}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    return @results
  end
end    