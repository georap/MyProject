class VehiclesController < ApplicationController
	include ApplicationHelper
	#access all: [], user: {:destroy, :new, :create, :update, :edit, :index }, site_admin: :all
	#access guest_user: [:index]
	before_action :check_guest_user

	def new
		@vehicle=Vehicle.new
		string=params[:location]
		location=string.split(',')
		station_id=params[:my_station]
		@area=Station.find_by_id(station_id).area
		#@area=location[1].tr("0-9", "").gsub(/\s+/, '')
	end

	def create
		@vehicle=Vehicle.new(vehicle_params)
		respond_to do |format|
			if @vehicle.save
				format.html{redirect_to station_path(@vehicle.station_id), notice: 'Η εγγραφή ολοκληρώθηκε'}
			else
				format.html{render :new}
			end

		end
	end

	def index
		#https://stackoverflow.com/questions/12719354/rails-3-return-query-results-to-bottom-of-form-page?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
	    #lista me oxhmata pou exei o xrhsths,tous mhnes pou exei, prathria pou exei balei kausima o xrhsths,
	    @vehicle=Vehicle.where(user_id: current_user.id)
	    @oxhmata=Array.new
	    @mhnes=Array.new
	    stations=Array.new
	    @prathrio=Array.new
	    @fuel_type=Array.new
	    puts @vehicle.size
	    if(!params[:my_station].nil?)
	    	#puts "mphkame ston vehicles controller  #{ params[:my_station]}"
	      	station_id=Station.find_by_name(params[:my_station]).id
	      	@vehicle=Vehicle.where(user_id: current_user.id).where(station_id: station_id)
	      	#puts @vehicle.inspect
	      	
	      	
	    	if(!params[:my_vehicle].nil?)
	      		puts "EEEEEEEE mphkame ston vehicles controller  #{ params[:my_vehicle]} #{station_id}"
	      		@vehicle=Vehicle.where(user_id: current_user.id).where(station_id: station_id).where(name:params[:my_vehicle])
	    	end      
	    end
	    puts @vehicle.size
	    @vehicle.each do|vehicle| 
	      if(!@oxhmata.include?(vehicle.name))
	        @oxhmata.insert(0,vehicle.name)
	      end
	      if(!@mhnes.include?(vehicle.fuel_date.month))
	        @mhnes.insert(0,vehicle.fuel_date.month)
	      end
	      if(!stations.include?(vehicle.station_id))
	        stations.insert(0,vehicle.station_id)
	      end
	      if(!@fuel_type.include?(vehicle.fuel_type))
	        @fuel_type.insert(0,vehicle.fuel_type)
	      end
	    end
	    @oxhmata.insert(0,"none")
	    @mhnes.insert(0,"all")
	    puts @oxhmata,@mhnes
	    @temp_oxhmata=@oxhmata.to_json.html_safe
	    stations.each do|i|
	    	@prathrio.insert(0,Station.find_by_id(i).name)
	    end
	    @prathrio.insert(0,"none")
	    #na ftiaksw format js gia na pairnei tis allages stis times twn selectors
	   	respond_to :html,:js
			
	end

	def edit
		@vehicle=Vehicle.find(params[:id])
	end

	def update
		@vehicle=Vehicle.find(params[:id])
		respond_to do |format|
	      	if @vehicle.update(vehicle_params)
	        	format.html { redirect_to pages_UserProfile_path, notice: 'The record successfully updated.' }
	      	else
	       	 	format.html { render :edit }
	      	end
	    end
	end

	def destroy
 		@vehicle=Vehicle.find(params[:id])
    	@vehicle.destroy
    	respond_to do|format|
      		format.html{redirect_to pages_UserProfile_path, notice: 'The record successfully deleted'}
      	end
	end

	private


	def vehicle_params
		params.require(:vehicle).permit(:name, :kilometers, :liters,:price ,:fuel_date, :fuel_type,:area,:user_id, :station_id)
	end
end
