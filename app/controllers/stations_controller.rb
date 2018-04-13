class StationsController < ApplicationController

	def index
		@station_items=Station.all
	end

	def show
		@station_item=Station.find(params[:id])
	end

	def new
		@station_item=Station.new
		string=params[:latlng].tr('()','')
		@newLatLong=string.split(',')
		@newLatLong[0].to_f
		@newLatLong[1].to_f
		puts "PARAMETERES: #{@newLatLong}"
	end

	def create
		@station_item=Station.new(station_params)
		respond_to do |format|
			if @station_item.save
				format.html{redirect_to stations_path, notice: 'Your Station is now Live.'}
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
