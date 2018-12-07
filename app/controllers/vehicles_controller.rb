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
	    #@vehicle=Vehicle.where(user_id: current_user.id)
	    @oxhmata=Array.new
	    @mhnes=Array.new
	    @stations=Array.new
	    @prathrio=Array.new
	    @fuel_type=Array.new
	    @second_vehicle=Array.new
	    @flag_vehicles=false
	    @flag_fuel=false
	    @flag_no_Station=false
	    #puts @vehicle.size
	    puts params[:got_checked].nil?
	    if(params[:got_checked]=="station"&& params[:my_vehicle].nil?)
	    	@vehicle=Vehicle.where(user_id: current_user.id)
	    	@stations=fill_stations()
		    puts "GOT CHECKED"
		    puts @prathrio
	    	if(!params[:my_station].nil?)
			    puts "mphkame ston vehicles controller  #{ params[:my_station]}"
			    element=params[:my_station].to_i
			    			    puts "to id einai #{@stations[element]}"
			    station_name=@prathrio[element]
			    station_id=@stations[element]
			    if(station_name!="none")
			    	dummy_var=fill_vehicles(station_id)
		    		
			    end
			    
		    	@oxhmata.insert(0,"none")
		    	@flag_vehicles=true  
			end
			puts "oxhmata #{@oxhmata}"
			@prathrio=@prathrio.to_json.html_safe
			@oxhmata=@oxhmata.to_json.html_safe
			@stations=@stations.to_json.html_safe
		    respond_to do |format|
	            format.js
	        end

	   	end
	   	if(!params[:my_vehicle].nil?)
	   		
	   		if(params[:got_checked]=="station")
	   			@vehicle=Vehicle.where(user_id: current_user.id)
		    	@stations=fill_stations()
			    puts @prathrio
			    station_element=params[:my_station].to_i
				station_name=@prathrio[station_element]
				puts "to id einai #{@stations[station_element]}"
				station_id=@stations[station_element]
				dummy_var=fill_vehicles(station_id)
				@oxhmata.insert(0,"none")
				#puts @oxhmata
				puts station_name
				vehicle_element=params[:my_vehicle].to_i
				vehicle_name=@oxhmata[vehicle_element]
				puts vehicle_name
				if(vehicle_name!="none")
					puts "HAAAAAAAAAAAAAAAAA"
					@vehicle=Vehicle.where(user_id: current_user.id).where(station_id:station_id).where(name: vehicle_name)
					@vehicle.each do|vehicle| 
				    	if(!@fuel_type.include?(vehicle.fuel_type))
				        	@fuel_type.insert(0,vehicle.fuel_type)
				      	end
				    end
				    puts @fuel_type
				end
				
			else
				@vehicle=Vehicle.where(user_id: current_user.id)
				@vehicle.each do|vehicle| 
					if(!@oxhmata.include?(vehicle.name))
						@oxhmata.insert(0,vehicle.name)
					end
				end
				@oxhmata.insert(0,"none")
				puts @oxhmata
				vehicle_element=params[:my_vehicle].to_i
				vehicle_name=@oxhmata[vehicle_element]
				if(vehicle_name!="none")
					@vehicle=Vehicle.where(user_id: current_user.id).where(name: vehicle_name)
					@vehicle.each do|vehicle| 
				    	if(!@fuel_type.include?(vehicle.fuel_type))
				        	@fuel_type.insert(0,vehicle.fuel_type)
				      	end
				    end
				    puts @fuel_type
				end
			end
			@flag_fuel=true
			fill_second_vehicle(station_id)
			@fuel_type=@fuel_type.to_json.html_safe
			@prathrio=@prathrio.to_json.html_safe
			@oxhmata=@oxhmata.to_json.html_safe
			respond_to do |format|
	            format.js
	        end
		end
		
	    if(params[:got_checked]=="noStation" && params[:my_vehicle].nil?)
	    	@vehicle=Vehicle.where(user_id: current_user.id)
	    	@vehicle.each do|vehicle| 
				if(!@oxhmata.include?(vehicle.name))
					@oxhmata.insert(0,vehicle.name)
				end
			end
			@oxhmata.insert(0,"none")
			@flag_no_Station=true
	    	@fuel_type=@fuel_type.to_json.html_safe
			@prathrio=@prathrio.to_json.html_safe
			@oxhmata=@oxhmata.to_json.html_safe
			respond_to do |format|
	            format.js
	        end
	    end
=begin
	    if(params[:got_checked]=="comparison")
	    	@vehicle=Vehicle.all
	    	@vehicle.each do|vehicle| 
				if(!@second_vehicle.include?(vehicle.name))
					@second_vehicle.insert(0,vehicle.name)
				end
			end
			@second_vehicle.insert(0,"none")
			@second_vehicle=@second_vehicle.to_json.html_safe
	    	@fuel_type=@fuel_type.to_json.html_safe
			@prathrio=@prathrio.to_json.html_safe
			@oxhmata=@oxhmata.to_json.html_safe
			respond_to do |format|
	            format.js
	        end
	    end

=end	    
	    #puts @vehicle.size
=begin	    @vehicle.each do|vehicle| 
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
	    @oxhmata=@oxhmata.to_json.html_safe
	    stations.each do|i|
	    	@prathrio.insert(0,Station.find_by_id(i).name)
	    end
	    @prathrio.insert(0,"none")
	    #na ftiaksw format js gia na pairnei tis allages stis times twn selectors
=end	   	#respond_to :html,:js
	   	
			
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

	#put elements in @prathria array
	def fill_stations
		temp_array=Array.new
		@vehicle.each do|vehicle| 
		      	if(!temp_array.include?(vehicle.station_id))
	        		temp_array.insert(-1,vehicle.station_id)
	      		end
		end
		temp_array.each do|i|
	    		@prathrio.insert(-1,Station.find_by_id(i).name)
	    end
		@prathrio.insert(0,"none")
		temp_array.insert(0,-35)
		#temp_array has the ids of stations
		return temp_array
	end

	#put elements in @oxhmata array
	def fill_vehicles(id)
		#puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE #{station_name}"
		#station_id=Station.where(name:station_name).first.id
		station_id=Station.find_by_id(id)
		puts station_id
		@vehicle=Vehicle.where(user_id: current_user).where(station_id: station_id)
		puts @vehicle.size
		@vehicle.each do|vehicle| 
			if(!@oxhmata.include?(vehicle.name))
				@oxhmata.insert(0,vehicle.name)
			end
		end
		return station_id
	end

	def fill_second_vehicle(id)
		#compare with only vehicles that are in the station that user choose
		temp_collection=Vehicle.where(station_id: id).pluck(:name).uniq
		puts temp_collection
	    	#temp_collection.each do|vehicle| 
				#if(!@second_vehicle.include?(vehicle.name))
					#@second_vehicle.insert(0,vehicle.name)
				#end
			#end
			@second_vehicle=temp_collection
			@second_vehicle.insert(0,"none")
			@second_vehicle=@second_vehicle.to_json.html_safe
	end
end
