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

  # def europe
  #   @location_arr = []
  #   arr = [{:full_name=>"Amsterdam", :country => "Netherlands" ,:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTLmd-hXV0HDpw1tSYfr67duY_bVRHKTXSVLL1gY-GT6VgVyDju",:name=>"AMS-sky"},{:full_name=>"Prague", :name=>"PRG-sky",:country=>"Czech Republic",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUZB7bv_F68WF_OwpeDWGvhElveDgKpYR58ZzZRaSRUBU5iBLZ5g"},{:full_name=>"Budapest", :name=>"BUD-sky", :country=>"Budapest",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRq3R6UcFpcuhimmnOMV7bp_YEJi7h4REp1P1bvNN68SDszgjbjPQ"},{:full_name=>"Barcelona", :country=>"Spain",:name=>"BCN-sky",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShPwDFUPi6qYftQjIassJdMv5f5Q4yVX0q8H_-ojCN-nZSRAKy"},{:full_name=>"Venice", :name=>"VCE-sky",:country=>"Italy",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlRPu2iXjvA9S2lCam2cJSGgxJesbqXu-yjbgHEGD-kLhpH89V"},{:full_name=>"Lisbon", :name=>"LIS-sky",:country=>"Portugal",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIhR7mXOd-5vFtw8v6QQdIX04pDtGfyqMjiz2Wb0aSdxQBULTYMw"},{:full_name=>"Paris", :name=>"CDG-sky",:country=>"France",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQoRIYMJJ5gg-Kox8IaMgOZPvvz3cXdeaz_8eU1u-S-DBrvJP6x"},{:full_name=>"Vienna", :name=>"VIE-sky",:country=>"Austria",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSkksIzpkK6xpOpL8cibKlXiiUVGdf5MHU12SujwiEX9rb2k9auow"},{:full_name=>"Berlin", :name=>"BERL-sky",:country=>"Germany",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSzmM1h31i2GWGKHlC9iJ5gx00OramS4DIM7cpFRSDBBOEKJMiN"}]

  #   @country = "europe"
  #   arr.each do |ar|
  #     h = Hash.new
  #     obj = {"country"=>"#{cookies[:country]}","currency"=>"#{cookies[:currency]}","locale"=>"en-US","originplace"=>"#{cookies[:latitude]},#{cookies[:longitude]}-latlong","destinationplace"=>ar[:name],"outbounddate"=>Date.today.strftime,"inbounddate"=>Date.today.at_end_of_month.strftime,"children"=>"0","infants"=>"0","cabinclass"=>"Economy","adults"=>"1"}
  #     response = Scanner.live_price(obj)
  #     @prices = HTTParty.get(response[:prices_url])
  #     if @prices["Legs"].present?
  #       set_hash_2
  #     end
  #     if @cheap.present?
  #       h[:price] = @cheap.first["TotalPrice"]
  #       h[:name] = ar[:full_name]
  #       h[:image] = ar[:img]
  #       h[:country] = ar[:country]
  #       @location_arr.push(h)
  #     end
  #   end
  #   respond_to do |format|
  #     format.js 
  #   end
  # end

  # def africa
  #   @location_arr = []    
  #   arr = [{:full_name=>"Marrakech", :country => "Morocco" ,:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/6a/4f/f1/marrakech.jpg",:name=>"RAK-sky"},{:full_name=>"Cape Town", :name=>"CPT-sky",:country=>"South Africa",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/6a/4f/1e/cape-town.jpg"},{:full_name=>"Fes", :name=>"FEZ-sky", :country=>"Morocco",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/17/65/53/marruecos.jpg"},{:full_name=>"Victoria Falls", :country=>"Zimbabwe",:name=>"VFA-sky",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/5f/81/07/victoria-falls-small.jpg"},{:full_name=>"Zanzibar", :name=>"ZNZ-sky",:country=>"Tanzania",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/cc/05/0e/nakupenda-beach.jpg"},{:full_name=>"Cairo", :name=>"CAI-sky",:country=>"Egypt",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRi_K3fpAl3kexaXWkEbze4Qoc1ULYjs1r-IbXJjVxf7Awr6Bu4"},{:full_name=>"Nairobi", :name=>"WIL-sky",:country=>"Kenya",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/03/da/de/46/nairobi.jpg"},{:full_name=>"Arusha", :name=>"ARK-sky",:country=>"Tanzania",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/40/58/b8/il-vento-che-alza-il.jpg"}]

  #   @country = "africa"
  #   arr.each do |ar|
  #     h = Hash.new
  #     obj = {"country"=>"#{cookies[:country]}","currency"=>"#{cookies[:currency]}","locale"=>"en-US","originplace"=>"#{cookies[:latitude]},#{cookies[:longitude]}-latlong","destinationplace"=>ar[:name],"outbounddate"=>Date.today.strftime,"inbounddate"=>Date.today.at_end_of_month.strftime,"children"=>"0","infants"=>"0","cabinclass"=>"Economy","adults"=>"1"}
  #     response = Scanner.live_price(obj)
  #     @prices = HTTParty.get(response[:prices_url])
  #     if @prices["Legs"].present?
  #       set_hash_2
  #     end
  #     if @cheap.present?
  #       h[:price] = @cheap.first["TotalPrice"]
  #       h[:name] = ar[:full_name]
  #       h[:image] = ar[:img]
  #       h[:country] = ar[:country]
  #       @location_arr.push(h)
  #     end
  #   end
  #   respond_to do |format|
  #     format.js 
  #   end
  # end

  # def asia
  #   @location_arr = []
  #   arr = [{:full_name=>"Dubai", :country => "UAE" ,:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQbPPpmzrfJrTPhCZ6-fizWQP0DYfOEAEW0vjT5ksP5uimw6mdpWw",:name=>"DXB-sky"},{:full_name=>"Tel Aviv", :name=>"TLV-sky",:country=>"Israel",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQ7TAKApuse-FT33F2oHkYB_PxV4Jj-GtrlT3pkJ94aVwuq1PDw"},{:full_name=>"Hurghada", :name=>"HRG-sky", :country=>"Egypt",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxL4XibVk4o6k3LIOjgt2cFatWw3OfPh9gzG5pLhBJfgSuAEtk"},{:full_name=>"Sharm el Sheikh", :country=>"Egypt",:name=>"SSH-sky",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn8__xNIILe2ubUZjcJL-9y0oibaKjxT8LIejTxUN0uOBuu-h5"},{:full_name=>"Abu Dhabi", :name=>"AUH-sky",:country=>"UAE",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSZJ9U6RqWhGH9UJ7_ROSR-sQZWhR_UsEc0s8enONkfUQtYrTMYFg"},{:full_name=>"Cairo", :name=>"CAI-sky",:country=>"Egypt",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRi_K3fpAl3kexaXWkEbze4Qoc1ULYjs1r-IbXJjVxf7Awr6Bu4"},{:full_name=>"Luxor", :name=>"LXR-sky",:country=>"Egypt",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRmTUJmoOsi-l9bnXQL8lhd5cUFTUeOXPwxX8zmD3PteJOVSE5L4A"},{:full_name=>"Eilat", :name=>"ETH-sky",:country=>"Israel",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/7d/45/66/eilat.jpg"},{:full_name=>"Doha", :name=>"DOH-sky",:country=>"QATAR",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/82/5d/79/doha.jpg"},{:full_name=>"Marsa Alam", :name=>"RMF-sky",:country=>"Egypt",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/03/de/03/da/marsa-alam.jpg"}]

  #   @country = "asia"
  #   arr.each do |ar|
  #     h = Hash.new
  #     obj = {"country"=>"#{cookies[:country]}","currency"=>"#{cookies[:currency]}","locale"=>"en-US","originplace"=>"#{cookies[:latitude]},#{cookies[:longitude]}-latlong","destinationplace"=>ar[:name],"outbounddate"=>Date.today.strftime,"inbounddate"=>Date.today.at_end_of_month.strftime,"children"=>"0","infants"=>"0","cabinclass"=>"Economy","adults"=>"1"}
  #     response = Scanner.live_price(obj)
  #     @prices = HTTParty.get(response[:prices_url])
  #     if @prices["Legs"].present?
  #       set_hash_2
  #     end
  #     if @cheap.present?
  #       h[:price] = @cheap.first["TotalPrice"]
  #       h[:name] = ar[:full_name]
  #       h[:image] = ar[:img]
  #       h[:country] = ar[:country]
  #       @location_arr.push(h)
  #     end
  #   end
  #   respond_to do |format|
  #     format.js 
  #   end
  # end
end
