require "scanner"
require "will_paginate/array"
class FlightsController < ApplicationController
  def live_prices
    response = Scanner.live_price(params[:flight])
    cookies[:prices_url] = response[:prices_url]
    cookies[:prices] = response[:prices]
    @prices = HTTParty.get(cookies[:prices_url])
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js { render "refresh"}
    end
  end

  def test 
    @prices = JSON.parse($redis.get("prices")) 
    @cheap = JSON.parse($redis.get("cheap"))
    @duration = JSON.parse($redis.get("duration"))  
    render template: "flights/live_prices"
  end

  def refresh
    @prices = HTTParty.get(cookies[:prices_url])
    if @prices["Legs"].present?
      set_hash
    end
    respond_to do |format|
      format.js 
    end
  end
  def fetch_loc
    @location_arr = []
    arr = []
    euro_arr = [{:full_name=>"Amsterdam", :country => "Netherlands" ,:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTLmd-hXV0HDpw1tSYfr67duY_bVRHKTXSVLL1gY-GT6VgVyDju",:name=>"AMS-sky"},{:full_name=>"Prague", :name=>"PRG-sky",:country=>"Czech Republic",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTUZB7bv_F68WF_OwpeDWGvhElveDgKpYR58ZzZRaSRUBU5iBLZ5g"},{:full_name=>"Budapest", :name=>"BUD-sky", :country=>"Budapest",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRq3R6UcFpcuhimmnOMV7bp_YEJi7h4REp1P1bvNN68SDszgjbjPQ"},{:full_name=>"Barcelona", :country=>"Spain",:name=>"BCN-sky",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShPwDFUPi6qYftQjIassJdMv5f5Q4yVX0q8H_-ojCN-nZSRAKy"},{:full_name=>"Venice", :name=>"VCE-sky",:country=>"Italy",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlRPu2iXjvA9S2lCam2cJSGgxJesbqXu-yjbgHEGD-kLhpH89V"},{:full_name=>"Lisbon", :name=>"LIS-sky",:country=>"Portugal",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIhR7mXOd-5vFtw8v6QQdIX04pDtGfyqMjiz2Wb0aSdxQBULTYMw"},{:full_name=>"Paris", :name=>"CDG-sky",:country=>"France",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQoRIYMJJ5gg-Kox8IaMgOZPvvz3cXdeaz_8eU1u-S-DBrvJP6x"},{:full_name=>"Vienna", :name=>"VIE-sky",:country=>"Austria",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSkksIzpkK6xpOpL8cibKlXiiUVGdf5MHU12SujwiEX9rb2k9auow"},{:full_name=>"Berlin", :name=>"BERL-sky",:country=>"Germany",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSzmM1h31i2GWGKHlC9iJ5gx00OramS4DIM7cpFRSDBBOEKJMiN"}]

    us_arr = [{:full_name=>"Newyork", :country => "USA" ,:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFKQ-a_Jt8MnYq_27TNzgKTjPMm5H7NWsYNS4lfFfXhvj6ZYN8YA",:name=>"JFK-sky"},{:full_name=>"Las Vegas", :name=>"LAS-sky",:country=>"USA",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTXdZXhV-jwpjAtJN0pKCrUBXL8WQRjO2OLxqZm-BKtA8DJwojE"},{:full_name=>"San Francisco", :name=>"SFO-sky", :country=>"USA",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSsAngQuSnE-6Lvi_F4P8_S8N7L4a1brkXc6ijgk17W2ydVPy4YPA"},{:full_name=>"Orlando", :country=>"USA",:name=>"MCO-sky",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcR8x64iVjmFPFxoBaYeR-FlZwDFMMlrUfx5rDXvwgUx7e8iJQKpiw"},{:full_name=>"Los Angeles", :name=>"LAX-sky",:country=>"USA",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQ7K8OuBPLKazMoUEEuvvSUgjx6DLn3Eux9xARCuZ86bDdnJ7cm"},{:full_name=>"Miami", :name=>"MIA-sky",:country=>"USA",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgt52WmDs44JgwixxsaZgvyG4639EsZkwadC0rp7p3YfUC0TUx"},{:full_name=>"Washington DC", :name=>"DCA-sky",:country=>"USA",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQi-nfB_0crB9b259kTOk4VTcrMyS8SvctxUfSBzpxLAyPKesA8"},{:full_name=>"Boston", :name=>"BOS-sky",:country=>"USA",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcS_bU1qecMzSV5z9CSa3VnnM7yzVA4RY9WcCQM_QezMmB1YmVRT"},{:full_name=>"Chicago", :name=>"ORD-sky",:country=>"USA",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQ97Jg7vDWz8SIV1qzvcehGYguz5MOjyxVZzzu-TKHf6sl1_zFB"},{:full_name=>"Honolulu", :name=>"HNL-sky",:country=>"USA",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQUwvCYK3ipM2r1_UOtmXszoDEwG0fBqqrysQh0wHXdWuBjmBRqLA"}]
    asia_arr = [{:full_name=>"Dubai", :country => "UAE" ,:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQbPPpmzrfJrTPhCZ6-fizWQP0DYfOEAEW0vjT5ksP5uimw6mdpWw",:name=>"DXB-sky"},{:full_name=>"Tel Aviv", :name=>"TLV-sky",:country=>"Israel",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcQ7TAKApuse-FT33F2oHkYB_PxV4Jj-GtrlT3pkJ94aVwuq1PDw"},{:full_name=>"Hurghada", :name=>"HRG-sky", :country=>"Egypt",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxL4XibVk4o6k3LIOjgt2cFatWw3OfPh9gzG5pLhBJfgSuAEtk"},{:full_name=>"Sharm el Sheikh", :country=>"Egypt",:name=>"SSH-sky",:img=>"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTn8__xNIILe2ubUZjcJL-9y0oibaKjxT8LIejTxUN0uOBuu-h5"},{:full_name=>"Abu Dhabi", :name=>"AUH-sky",:country=>"UAE",:img=>"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSZJ9U6RqWhGH9UJ7_ROSR-sQZWhR_UsEc0s8enONkfUQtYrTMYFg"},{:full_name=>"Cairo", :name=>"CAI-sky",:country=>"Egypt",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRi_K3fpAl3kexaXWkEbze4Qoc1ULYjs1r-IbXJjVxf7Awr6Bu4"},{:full_name=>"Luxor", :name=>"LXR-sky",:country=>"Egypt",:img=>"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRmTUJmoOsi-l9bnXQL8lhd5cUFTUeOXPwxX8zmD3PteJOVSE5L4A"},{:full_name=>"Eilat", :name=>"ETH-sky",:country=>"Israel",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/7d/45/66/eilat.jpg"},{:full_name=>"Doha", :name=>"DOH-sky",:country=>"QATAR",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/82/5d/79/doha.jpg"},{:full_name=>"Marsa Alam", :name=>"RMF-sky",:country=>"Egypt",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/03/de/03/da/marsa-alam.jpg"}]
    africa_arr = [{:full_name=>"Marrakech", :country => "Morocco" ,:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/6a/4f/f1/marrakech.jpg",:name=>"RAK-sky"},{:full_name=>"Cape Town", :name=>"CPT-sky",:country=>"South Africa",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/6a/4f/1e/cape-town.jpg"},{:full_name=>"Fes", :name=>"FEZ-sky", :country=>"Morocco",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/17/65/53/marruecos.jpg"},{:full_name=>"Victoria Falls", :country=>"Zimbabwe",:name=>"VFA-sky",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/5f/81/07/victoria-falls-small.jpg"},{:full_name=>"Zanzibar", :name=>"ZNZ-sky",:country=>"Tanzania",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/07/cc/05/0e/nakupenda-beach.jpg"},{:full_name=>"Cairo", :name=>"CAI-sky",:country=>"Egypt",:img=>"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRi_K3fpAl3kexaXWkEbze4Qoc1ULYjs1r-IbXJjVxf7Awr6Bu4"},{:full_name=>"Nairobi", :name=>"WIL-sky",:country=>"Kenya",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/03/da/de/46/nairobi.jpg"},{:full_name=>"Arusha", :name=>"ARK-sky",:country=>"Tanzania",:img=>"https://media-cdn.tripadvisor.com/media/photo-s/01/40/58/b8/il-vento-che-alza-il.jpg"}]

    if params[:loc] == "europe"
      arr = euro_arr
    elsif params[:loc] == "usa"
      arr = us_arr
    elsif params[:loc] == "asia"
      arr = asia_arr
    elsif params[:loc] == "africa"
      arr = africa_arr
    end
    @country = params[:loc]
    arr.each do |ar|
      h = Hash.new
      obj = {"country"=>"US","currency"=>"USD","locale"=>"en-US","originplace"=>"LOND-sky","destinationplace"=>ar[:name],"outbounddate"=>Date.today.strftime,"inbounddate"=>Date.today.at_end_of_month.strftime,"children"=>"0","infants"=>"0","cabinclass"=>"Economy","adults"=>"1"}
      response = Scanner.live_price(obj)
      @prices = HTTParty.get(response[:prices_url])
      if @prices["Legs"].present?
        set_hash_2
      end
      if @cheap.present?
        h[:price] = @cheap.first["TotalPrice"]
        h[:name] = ar[:full_name]
        h[:image] = ar[:img]
        h[:country] = ar[:country]
        @location_arr.push(h)
      end
    end
    respond_to do |format|
      format.js 
    end
  end

  private
  def set_hash
    @cheap = @prices["Legs"]
    agents = @prices["Agents"]
    places = @prices["Places"]
    segments = @prices["Segments"]
    itineraries = @prices["Itineraries"]
    carriers = @prices["Carriers"]
    currencies = @prices["Currencies"]
    stops = @prices["Stops"]
    empty = []
    @cheap.each_with_index do |(k, v), index|
      @cheap[index]["carrierDetail"] = []
      @cheap[index]["Carriers"].each_with_index do |c, cc|
        @cheap[index]["carrierDetail"][cc] = carriers.find { |h| h['Id'] == c }
      end
      @cheap[index]["Operators"] = []
      @cheap[index]["OperatingCarriers"].each_with_index do |c, cc|
        @cheap[index]["Operators"][cc] = carriers.find { |h| h['Id'] == c }
      end
      @cheap[index]["Segments"] = []
      @cheap[index]["SegmentIds"].each_with_index do |c, cc|
        @cheap[index]["Segments"][cc] = segments.find { |h| h['Id'] == c }
      end
      @cheap[index]["StopPlaces"] = []
      @cheap[index]["Stops"].each_with_index do |c, cc|
        @cheap[index]["StopPlaces"][cc] = places.find { |h| h['Id'] == c } if !places.find { |h| h['Id'] == c }.nil?
      end
      @cheap[index]["Destination"] = places.find { |h| h['Id'] == @cheap[index]["DestinationStation"] }
      @cheap[index]["Origin"] = places.find { |h| h['Id'] == @cheap[index]["OriginStation"] } 
      @cheap[index]["PriceInfo"] = []
      @cheap[index]["PriceInfo"] = itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }["PricingOptions"] if !itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }.nil?
      price = 0
      @cheap[index]["PriceInfo"].each do |p|
        price += p["Price"] 
      end
      @cheap[index]["TotalPrice"] = price.round(2)
      @cheap[index]["CurrencyCode"] = currencies.find { |h| h['Code'] == cookies[:currency]}["Symbol"] 
      
    end
    @cheap.delete_if{ |key, value| key["TotalPrice"]==0.0 }
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
    @duration  = @cheap.deep_dup
    @duration = @duration.sort_by { |k| k["Duration"]}
    # $redis.set("prices", @prices.to_json)
    # $redis.set("cheap", @cheap.to_json)
    # $redis.set("duration", @duration.to_json)
  end

  def set_hash_2
    @cheap = @prices["Legs"]
    agents = @prices["Agents"]
    places = @prices["Places"]
    segments = @prices["Segments"]
    itineraries = @prices["Itineraries"]
    carriers = @prices["Carriers"]
    currencies = @prices["Currencies"]
    stops = @prices["Stops"]
    empty = []
    @cheap.each_with_index do |(k, v), index|
      @cheap[index]["PriceInfo"] = []
      @cheap[index]["PriceInfo"] = itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }["PricingOptions"] if !itineraries.find { |h| h['OutboundLegId'] == @cheap[index]["Id"] }.nil?
      price = 0
      @cheap[index]["PriceInfo"].each do |p|
        price += p["Price"] 
      end
      @cheap[index]["TotalPrice"] = price.round(2)
      
    end
    @cheap.delete_if{ |key, value| key["TotalPrice"]==0.0 }
    @cheap = @cheap.sort_by { |k| k["TotalPrice"]}
  end
end
