task :import_geo_catalouge => :environment do
  @results = HTTParty.get("http://partners.api.skyscanner.net/apiservices/geo/v1.0?apikey=#{ENV['API_KEY']}",
    :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  )
  @results["Continents"].each do |c|
    continent = Continent.create(c_id: c["Id"], name: c["Name"])
    p "#{continent.name} saved"
    c["Countries"].each do |ctry|
      country = Country.create(c_id: ctry["Id"], currency: ctry["CurrencyId"], name: ctry["Name"], language: ctry["LanguageId"], continent_id: continent.id)
      p "#{country.name} saved"
      ctry["Cities"].each do |ct|
        city = City.create(c_id: ct["Id"], name: ct["Name"], iatacode: ct["IataCode"], latitude: ct["Location"].split(", ")[0], longitude: ct["Location"].split(", ")[1], country_id: country.id)
        p "#{city.name} saved"
        ct["Airports"].each do |aprt|
          airport = Airport.create(c_id: aprt["Id"], name: aprt["Name"], latitude: aprt["Location"].split(", ")[0], longitude: aprt["Location"].split(", ")[1], city_id: city.id)
          p "#{airport.name} saved"
        end
      end
    end
  end
end