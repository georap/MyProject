class StationsController < ApplicationController

	def index
		@station_items=Station.all
	end

	def show
		@station_item=Station.includes(:reviews).find(params[:id])
		@review=Review.new
		@flag=current_user.id
		#print "the reviews for current_user #{@station_item.reviews.where(user_id: 4).inspect()}"

	end

	def new
		@station_item=Station.new
		string=params[:latlng].tr('()','')
		@newLatLong=string.split(',')
		@newLatLong[0].to_f
		@newLatLong[1].to_f

	end

	def create
		@station_item=Station.new(station_params)
		respond_to do |format|
			if @station_item.save
				format.html{redirect_to root_path, notice: 'Your Station is now Live.'}
			else
				format.html{render :new}
			end

		end
	end

	private
	def station_params
		params.require(:station).permit(:name, :address, :latitude, :longitude)
	end

end
