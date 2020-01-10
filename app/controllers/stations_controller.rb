class StationsController < ApplicationController
	include ApplicationHelper
	before_action :check_guest_user, only: [:new,:create,:index, :edit, :update, :destroy]
	access site_admin: :all, user: [:new,:create,:show]

	def index
		@station_items=Station.all

	end

	def edit
		@station_item=Station.find(params[:id])
	end

	def update
		@station_item=Station.find(params[:id])
		respond_to do |format|
	      	if @station_item.update(station_params)
	        	format.html { redirect_to stations_path, notice: 'The record successfully updated.' }
	      	else
	       	 	format.html { render :edit }
	      	end
	    end
	end

	def destroy
		@station_item=Station.find(params[:id])
    	@station_item.destroy
    	respond_to do|format|
      		format.html{redirect_to stations_path, notice: 'The record successfully deleted'}
      	end
	end

	def show
		@station_item=Station.includes(:reviews).find(params[:id])
		@review=Review.new
 HEAD
		@flag=current_user.id
		@admin=is_admin
		#print "the reviews for current_user #{@station_item.reviews.where(user_id: 4).inspect()}"
 master

	end

	def new
		@station_item=Station.new
		string=params[:latlng].tr('()','')
		@newLatLong=string.split(',')
		@newLatLong[0].to_f
		@newLatLong[1].to_f
		results = Geocoder.search([@newLatLong[0], @newLatLong[1]])
		puts results.first.address_components_of_type(:city)
		results=results.first.address_components_of_type(:administrative_area_level_3).to_s
		data= results.split(",")
		@area= data[0].partition("=>").last.tr('"','')
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
		params.require(:station).permit(:name, :address, :latitude, :longitude, :area,:company)
	end
	
	def is_admin
		if (current_user.roles[0].to_s.include?("site_admin"))
			return true
		else
			return false
		end
	end
end
