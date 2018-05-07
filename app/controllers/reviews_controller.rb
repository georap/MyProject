class ReviewsController < ApplicationController
	def create
		@review= current_user.reviews.build(review_params)
	end

	private

	def review_params
		params.require(:review).permit(:content)
	end
end
