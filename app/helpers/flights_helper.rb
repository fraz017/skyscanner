module FlightsHelper
	def createStars(number)
		result = ''
		number.times do |n|
			result += '<img src="/assets/star.png" width="25"> '
		end
		return result
	end
end
