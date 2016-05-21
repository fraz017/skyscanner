class UserNotification < ActiveRecord::Base
	serialize :query, JSON
end
