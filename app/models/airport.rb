class Airport < ActiveRecord::Base
  belongs_to :city
  scope :search_by_airport, ->(query){ 
    (query ? where(["LOWER (name) LIKE ?",'%'+ query + '%']): {}).select("DISTINCT (name) name, c_id, city_id").limit(5)
  }
end
