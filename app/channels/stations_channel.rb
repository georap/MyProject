class StationsChannel < ApplicationCable::Channel
	def subscribed
		stream_from "stations_#{params['station_id']}_channel"
	end

	def unsubscribed
	end

	def send_review(data)
		current_user.reviews.create!(content: data['review'], station_id: data['station_id'])
	end
end