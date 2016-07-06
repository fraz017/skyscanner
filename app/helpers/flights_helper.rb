module FlightsHelper
	def createStars(number)
		result = ''
		number.times do |n|
			result += '<span class="glyphicon glyphicon-star" style="color:gold;"></span> '
		end
		return result
	end
end
