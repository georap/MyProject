class ReviewsController < ApplicationController

	def create
		@review= current_user.reviews.build(review_params)
	end

	def edit
		station=Station.find(params[:station_id])
		@review= station.reviews.find(params[:id])
	end

	def update
		station=Station.find(params[:station_id])
		@review= station.reviews.find(params[:id])
		
		respond_to do |format|
	      	if @review.update(review_params)
	        	format.html { redirect_to station_path(station), notice: 'The record successfully updated.' }
	      	else
	       	 	format.html { render :edit }
	      	end
	    end
	end

	def destroy
		@station= Station.find(params[:station_id])
		@review= @station.reviews.find(params[:id])
		@review.destroy
		redirect_to station_path(@station)
	end

	private

	def review_params
		params.require(:review).permit(:content)
	end
end
