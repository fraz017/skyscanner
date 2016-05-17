class City < ActiveRecord::Base
  belongs_to :country
  has_many :airports
  scope :search_by_city, ->(query){ 
    (query ? where(["LOWER (name) LIKE ?",'%'+ query + '%']) : {}).select("DISTINCT (name) name, c_id, id").limit(5)
  }
end
