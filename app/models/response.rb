class Response < ActiveRecord::Base
	serialize :result, JSON
	serialize :prices, JSON
end
