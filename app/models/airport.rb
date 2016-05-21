class Airport < ActiveRecord::Base
  belongs_to :city
  scope :search_by_airport, ->(query, city_id){ 
    (query ? where(["LOWER (name) LIKE ? AND city_id = ?",'%'+ query + '%', city_id]): {}).select("DISTINCT (name) name, c_id, city_id").limit(3)
  }
  scope :search_by_iatacode, ->(query){ 
    (query ? where(["LOWER (c_id) LIKE ?", query + '%']): {}).select("DISTINCT (c_id) c_id, name, city_id").limit(3)
  }
end
