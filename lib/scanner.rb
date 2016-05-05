class Scanner
  def self.live_price(object)
    @results = HTTParty.post("http://partners.api.skyscanner.net/apiservices/pricing/v1.0",
      :body => URI.encode_www_form(
        "apiKey" => ENV["API_KEY"],
        "country" => object["country"],
        "currency" => object["currency"],
        "locale" => object["locale"],
        "originplace" => object["originplace"],
        "destinationplace" => object["destinationplace"],
        "outbounddate" => object["outbounddate"],
        "inbounddate" => object["inbounddate"],
        "cabinclass" => object["cabinclass"],
        "adults" => object["adults"],
        "children" => object["children"],
        "infants" => object["infants"],
        "groupPricing" => false,
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
end    