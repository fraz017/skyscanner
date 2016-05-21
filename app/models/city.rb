class City < ActiveRecord::Base
  belongs_to :country
  has_many :airports
  scope :search_by_city, ->(query){ 
    (query ? where(["LOWER (name) LIKE ?",'%'+ query + '%']) : {}).select("DISTINCT (name) name, iatacode, c_id, id").limit(4)
  }
  scope :search_by_iatacode, ->(query){ 
    (query ? where(["LOWER (iatacode) LIKE ?", query + '%']) : {}).select("DISTINCT (iatacode) iatacode, name, c_id, id").limit(3)
  }
end
