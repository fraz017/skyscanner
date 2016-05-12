class WelcomeController < ApplicationController
  def index
  end

  def getCountries
    @countries = HTTParty.get("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/#{cookies[:country]}/#{cookies[:currency]}/en-US?apiKey=prtl6749387986743898559646983194&query=#{params[:term]}", :headers => {'Accept' => 'application/json' })
    data = Array.new
    @countries["Places"].each do |country|
      if country["CityId"].gsub("-sky","") != ""
        symbol=''
        if country['RegionId'] != '' 
          symbol = 'glyphicon glyphicon-plane'
        else
          symbol = 'glyphicon glyphicon-flag' 
        end
        value = "<span class=\"#{symbol}\"></span>   "+country["PlaceName"]+", "+ country["CountryName"]
        obj = {value: country["PlaceName"]+ ", "+ country["CountryName"], label: value, id: country["PlaceId"] }
        data.push(obj)
      end  
    end  
    render json: data
  end
end
