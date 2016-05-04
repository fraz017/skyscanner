class WelcomeController < ApplicationController
  def index
  end

  def getCountries
    @countries = HTTParty.get("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/#{cookies[:country]}/#{cookies[:currency]}/en-US?apiKey=prtl6749387986743898559646983194&query=#{params[:query]}", :headers => {'Accept' => 'application/json' })
    data = Array.new
    @countries["Places"].each do |country|
      if country["CityId"].gsub("-sky","") != ""
        obj = {value: country["PlaceName"], data: country["PlaceId"] }
        data.push(obj)
      end  
    end  
    render json: {suggestions: data}
  end
end
