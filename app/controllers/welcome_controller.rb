class WelcomeController < ApplicationController
  def index
  end

  def getCountries
    cities = City.search_by_city(params[:term])
    data = Array.new
    cities.each do |z| 
      h = Hash.new
      symbol = 'glyphicon glyphicon-flag'
      value = "<span class=\"#{symbol}\"></span>   "+z.name
      h["id"] = z.c_id
      h["value"] = "#{z.name}"
      h["label"] = value
      data.push(h)
      airports = Airport.search_by_airport(params[:term], z.id)
      airports.each do |z| 
        h = Hash.new
        symbol = 'glyphicon glyphicon-plane'
        value = "<span class=\"#{symbol}\" style='margin-left:25px;'></span>   "+z.name
        h["id"] = z.c_id
        h["value"] = "#{z.name}"
        h["label"] = value
        data.push(h)
      end
    end
    render :json => data 
  end
end
