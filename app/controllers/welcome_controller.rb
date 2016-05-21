class WelcomeController < ApplicationController
  def index
     cookies[:countryCode] = "US";
     cookies[:currencyCode] = "USD";
     cookies[:latitude] = 37.4192;
     cookies[:longitude] = -122.0574;
  end

  def getCountries
    cities = City.search_by_city(params[:term])
    data = Array.new
    cities.each do |z| 
      h = Hash.new
      symbol = 'glyphicon glyphicon-flag'
      value = "<span class=\"#{symbol}\"></span>   "+z.name + " (#{z.iatacode})"
      h["id"] = z.c_id
      h["value"] = "#{z.name}"
      h["label"] = value
      data.push(h)
      airports = Airport.search_by_airport(params[:term], z.id)
      airports.each do |z| 
        h = Hash.new
        symbol = 'glyphicon glyphicon-plane'
        value = "<span class=\"#{symbol}\" style='margin-left:25px;'></span>   "+z.name + " (#{z.c_id})"
        h["id"] = z.c_id
        h["value"] = "#{z.name}"
        h["label"] = value
        data.push(h)
      end
    end
    airports = Airport.search_by_iatacode(params[:term])
    airports.each do |z| 
      h = Hash.new
      symbol = 'glyphicon glyphicon-plane'
      value = "<span class=\"#{symbol}\"></span>   "+z.name + " (#{z.c_id})"
      h["id"] = z.c_id
      h["value"] = "#{z.name}"
      h["label"] = value
      data.push(h)
    end
    render :json => data 
  end
end
