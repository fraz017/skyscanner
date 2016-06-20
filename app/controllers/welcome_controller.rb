class WelcomeController < ApplicationController
  def index
     cookies[:countryCode] = "US";
     cookies[:currencyCode] = "USD";
     cookies[:latitude] = 37.4192;
     cookies[:longitude] = -122.0574;
     cookies[:locale] = "en-US";
  end

  def getCountries
    cities = City.search_by_city(params[:term])
    data = Array.new
    cities.each do |z| 
      h = Hash.new
      symbol = 'fa fa-flag'
      value = "<span class=\"#{symbol}\"></span>   "+z.name + " (#{z.iatacode})"
      h["id"] = z.c_id
      h["value"] = "#{z.name} (#{z.iatacode})"
      h["label"] = value
      data.push(h)
      airports = Airport.search_by_airport(params[:term], z.id)
      airports.each do |z| 
        h = Hash.new
        symbol = 'fa fa-plane'
        value = "<span class=\"#{symbol}\" style='margin-left:25px;'></span>   "+z.name + " (#{z.c_id})"
        h["id"] = z.c_id
        h["value"] = "#{z.name} (#{z.c_id})"
        h["label"] = value
        data.push(h)
      end
    end
    airports = Airport.search_by_iatacode(params[:term])
    airports.each do |z| 
      h = Hash.new
      symbol = 'fa fa-plane'
      value = "<span class=\"#{symbol}\"></span>   "+z.name + " (#{z.c_id})"
      h["id"] = z.c_id
      h["value"] = "#{z.name} (#{z.c_id})"
      h["label"] = value
      data.push(h)
    end
    render :json => data 
  end

  def getCountriesHotel
    market = cookies["countryCode"]
    currency = cookies["currency"]
    locale = "en-US"
    query = params["term"]
    @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/hotels/autosuggest/v2/#{market}/#{currency}/#{locale}/#{query}?apiKey=#{ENV['API_KEY']}",
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    )
    data = Array.new
    @results["results"].each do |r|
      h = Hash.new
      symbol = 'fa fa-building-o'
      value = "<span class=\"#{symbol}\"></span>    "+r["display_name"] + " "
      h["id"] = r["individual_id"]
      h["value"] = "#{r["display_name"]}"
      h["label"] = value
      data.push(h)
    end
    render :json => data 
  end
end
