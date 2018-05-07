class ReviewBroadcastJob < ApplicationJob
	queue_as :default

	def perform(review)
		ActionCable.server.broadcast "stations_#{review.station.id}_channel", review: render_review(review)
	end

	private
	def render_review(review)
		ReviewsController.render partial: 'reviews/review', locals: { review: review}
	end
end