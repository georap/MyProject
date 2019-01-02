class PagesController < ApplicationController
  include ApplicationHelper
  require 'range_tree'
  require 'date'
  #access all: [:home,:about,:contact], user: :all, site_admin: :all
  before_action :check_guest_user, only: [:UserProfile,:statistics]

  
	#IP panepisthmiou 195.130.121.45 ----> request.location
  require 'net/http'
	require 'freegeoip'
  require 'json'

  def home
    @user_auth=false
    @station_items=Station.new
    if (current_user.is_a?(GuestUser))
      @user_auth=false
    else
      @user_auth=true
    end
    text=ipRequest()
    data=JSON.parse(text)
    lat='latitude'
    long='longitude'
    puts data["city"]
    @ip=[0.0,0.0]
    if(data["city"]=="Ioannina")
      puts "no static"
      #emfanizei tous sta8mous mono gia ta giannena
      #@station_items=Station.where("area like ?", "%Ιωαννίνων%").or(Station.where("area like ?", "%Ιωάννινα%"))
      @station_items=Station.all
      @ip=[data[lat],data[long]]
    else
      puts "static"
      @station_items=Station.all
      @ip=[39.618008110280655,20.83890170776874]
    end
    
    
    puts @ip
  	@addresses=Array.new
  	
  	@station_items.each do|station_item|
    	name0=station_item.name
    	longitude0=station_item.longitude
    	latitude0=station_item.latitude
    	if(longitude0!=nil)&&(longitude0!=nil)
    		@addresses.insert(0,station_item)
    	end
  	end
  	@addresses=@addresses.to_json.html_safe

  end

  def UserProfile
    @flagJS=-1
    @tester=Array.new
    @litra_pinakas=Array.new
    @timh_pinakas=Array.new
    @stations_ids=Array.new
    @station_list=Array.new
    @stations_names=Array.new
    @date_pinakas=Array.new
    if(params[:liters_price_vehicle].nil?||params[:vehicle].nil?)
      @vehicle_list=Array.new
      @vehicle=Vehicle.where(user_id: current_user.id).order(fuel_date: :desc)

      #@vehicle=@vehicle.order(fuel_date: :desc)

      @vehicle.each do|vehicle|
        @vehicle_list.insert(-1,vehicle.name)    
      end

      @div_vehicle=@vehicle_list.uniq
      @div_vehicle.insert(0,"Επιλογή Οχήματος")
  end
    if(!params[:liters_price_vehicle].nil?)
      @flagJS=0
      puts "litra-price periptwsh"
      vehicle_name=params[:liters_price_vehicle]
      @temp_collection=Vehicle.where(user_id: current_user.id).where(name:vehicle_name).order(fuel_date: :asc)
      
      
      @temp_collection.each do|vehicle|
        if(vehicle.price==nil)
          @timh_pinakas.insert(-1,0)
        else
          @timh_pinakas.insert(-1,vehicle.price)
        end
        @date_pinakas.insert(-1,vehicle.fuel_date)
        @litra_pinakas.insert(-1,vehicle.liters)
      end

      

      #puts @date_pinakas,@litra_pinakas,@timh_pinakas,@vehicle_list,@station_list
      #puts "EDWWWWWWWWWWW"
      #puts @categories_list
      @date_pinakas=@date_pinakas.to_json.html_safe
      @litra_pinakas=@litra_pinakas.to_json.html_safe
      @timh_pinakas=@timh_pinakas.to_json.html_safe
      respond_to do |format|
            format.js
      end
      
    elsif (!params[:vehicle].nil?)
      puts "gemismata periptwsh"
      @flagJS=1
      vehicle_name=params[:vehicle]
     
      
      @vehicle=Vehicle.where(user_id: current_user.id).where(name:vehicle_name).order(:fuel_date)
      @vehicle.each do|element|
        @date_pinakas.insert(-1,element.fuel_date)
        @stations_ids.insert(-1,element.station_id)
      end
      @station_list=@stations_ids.uniq
      
      puts @station_list

      
      
      for i in 0..@station_list.size-1
        name=Station.find_by_id(@station_list[i]).name
        @stations_names.insert(-1,name)
      end

      @stations_ids=@stations_ids.to_json.html_safe
      @stations_names=@stations_names.to_json.html_safe
      @station_list=@station_list.to_json.html_safe
      @date_pinakas=@date_pinakas.to_json.html_safe
      respond_to do |format|
            format.js
      end
    end
  end

  def about
    #https://stackoverflow.com/questions/12719354/rails-3-return-query-results-to-bottom-of-form-page?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    #lista me oxhmata pou exei o xrhsths
    
    
  end

  def statistics
    @case=0
    @error_message=''
    @lt_per_km_monthly=Array.new
    @katanalwsh_mhna=0.0
    @katanalwsh_xronou=0.0
    string=params[:q]
    array=string.split(',')
    xronos=array[0]
    oxhma=array[1]
    station=array[2]
    fuel_type=array[3]
    sugkrish=array[4]
    if(sugkrish.include?("true"))
      sugkrish= true
    else
      sugkrish=false
    end
    #prepei na pros8esw anazhtsh me perioxh
    if(station.include?("none"))
      #otan einai none STATION mporei na upologisei aneksarthta apo to prathrio gia sugkekrimeno xrhsth 
      if(!oxhma.include?("none"))&&(xronos.include?("all"))
        #APOTELESMATA GIA OLO TO XRONO SUGKEKRIMENOU OXHMATOS TOU XRHSTH
        @case=0
        litra=0.0
        km=0.0
        @vehicle=Vehicle.where(user_id: current_user.id).where(name:oxhma).order(:fuel_date)
        km_array=Array.new
        lt_array=Array.new
        @array_date=Array.new
        @user_id=Array.new
        @vehicle_list=Array.new
        consumption_array=Array.new
        @litra_pinakas=Array.new
        @timh_pinakas=Array.new
        @prathria_list=Array.new
        if(@vehicle.size>2)
            @katanalwsh_pinakas=Array.new
            @date_pinakas=Array.new
            #temp_collection=@vehicle
            #@katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
            puts @katanalwsh_pinakas
            puts "hmeromhnia.."
            puts @date_pinakas
            
            
            #@katanalwsh_mhna=calculating(xronos.to_i)
            #upologizei th katanalwsh gia oloklhro to xrono
            last_km=@vehicle.last.kilometers.to_f
            first_km=@vehicle.first.kilometers.to_f
            km=last_km-first_km
             puts "REEEEEEEEEEEEEEEEEE #{km}"
            counter=0

            @vehicle.each do|vehicle|
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array.insert(-1,vehicle.kilometers)
              lt_array.insert(-1,vehicle.liters)
              @timh_pinakas.insert(-1,vehicle.price)
              @prathria_list.insert(-1,vehicle.station_id)
              counter+=1 
              if(counter<@vehicle.count)
                litra+=vehicle.liters

              end
            end
            puts "REEEEEEEEEEEEEEEEEE #{litra}"
            @katanalwsh_xronou=100*litra/km
            @katanalwsh_xronou=@katanalwsh_xronou.round(3)
        end
        
        consumption_array=find_consumption_2(km_array,lt_array,0)
        puts consumption_array
        puts @case
        #@katanalwsh_pinakas=fill_katanalwsh_array(consumption_array,0)
        @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,0)
        puts "--------------------------------"
        puts @katanalwsh_pinakas
        puts km_array,lt_array,@array_date
        @km_graph=Array.new
        for i in 0..km_array.size-1 
          if(i!=km_array.size-1)
            @km_graph.insert(-1,km_array[i+1]-km_array[i])
          end
        end
        puts @km_graph
        @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
        @date_pinakas=@array_date
        @litra_pinakas=lt_array
        @date_pinakas=@date_pinakas.to_json.html_safe
        @prathria_uniq_list=@prathria_list.uniq
      elsif(!oxhma.include?("none"))&&(!xronos.include?("all"))
          #Ypologizei xiliometra kai litra gia sugkekrimeno mhna
          @case=1
          @vehicle=Vehicle.where(user_id: current_user.id).where(name:oxhma).where('extract(month from fuel_date) = ?', xronos).order(:fuel_date)
          if(@vehicle.size>1)
            @katanalwsh_pinakas=Array.new
            @date_pinakas=Array.new
            temp_collection=@vehicle
            @katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
            puts @katanalwsh_pinakas
            puts "hmeromhnia.."
            puts @date_pinakas
            @date_pinakas=@date_pinakas.to_json.html_safe
            @katanalwsh_mhna=calculating(xronos.to_i)
            @vehicle_name=oxhma.to_json.html_safe
            #print "KATANALWSH #{@katanalwsh_mhna}"
          else 
            @error_message='DEN UPARXEI EGGRAFH GIA MHNA '+xronos +' GIA TO AUTOKINHTO '+ oxhma +' POU EPILEKSATE '
            puts "DEN UPARXEI EGGRAFH ME TO SUGKEKRIMENO MHNA GIA TO AUTOKINHTO POU EPILEKSATE"
          end
      elsif(oxhma.include?("none")) 
          @error_message='DEN MPOREITE NA EPILEKSETE NONE STASION KAI NONE VEHICLE'
          puts "DEN MPOREITE NA EPILEKSETE NONE STASION KAI NONE VEHICLE"
      end
    else
      #alliws upologizei me bash to prathrio
      if(xronos.include?("all"))&&(oxhma.include?("none"))
        #katanalwsh gia pollapla oxhmata tou prathriou pou exei balei o xrhsths kausima
        @case=2
        @station_id=Station.find_by_id(station)
        @vehicle=Vehicle.where(station_id: @station_id.id).where(user_id: current_user).order(:fuel_date)
        @oxhmata_list=Array.new
        @user_id=Array.new
        @array_date=Array.new
        km_array=Array.new
        lt_array=Array.new
        @vehicle_list=Array.new

        @vehicle.each do|vehicle| 
          if(!@oxhmata_list.include?(vehicle.name))
            @oxhmata_list.insert(0,vehicle.name)
          end
          @array_date.insert(-1,vehicle.fuel_date)
          km_array.insert(-1,vehicle.kilometers)
          lt_array.insert(-1,vehicle.liters)
          @vehicle_list.insert(-1,vehicle.name)
          @user_id.insert(-1,vehicle.user_id)
        end

        @katanalwsh_pinakas=Array.new
        @date_pinakas=Array.new
        @statistika=Array.new()
        litra=Array.new(@oxhmata_list)
        km=Array.new(@oxhmata_list)
        last_km=Array.new(@oxhmata_list)
        @lt_per_km_monthly=Array.new(@oxhmata_list)     
        for i in 0..@oxhmata_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(name: @oxhmata_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(name: @oxhmata_list[i]).first.kilometers
          temp_collection=@vehicle.where(name: @oxhmata_list[i])
          @katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
          #puts @vehicle.where(name: @oxhmata_list[i]).inspect
          #@statistika.insert(0,@katanalwsh_pinakas,@date_pinakas)
          @statistika.push([@katanalwsh_pinakas,@date_pinakas])
          #puts @katanalwsh_pinakas,@date_pinakas
          #puts "allo oxhma"
        end
        puts @statistika
        puts "-------------------------------"
        @statistika=@statistika.to_json.html_safe
        @name_list=@oxhmata_list.to_json.html_safe

        @vehicle.each do|vehicle|
          for i in 0..@oxhmata_list.size-1
            if(@oxhmata_list[i].include?(vehicle.name))
              if(last_km[i]!=vehicle.kilometers)
                litra[i]=litra[i]+vehicle.liters
              end
            end
          end
        end
        for i in 0..@oxhmata_list.size-1
          @lt_per_km_monthly[i]=100*litra[i]/km[i]
        end
        #puts station
        #puts @oxhmata_list
        #puts km
        #puts litra
        #puts @lt_per_km_monthly
        consumption_array=find_consumption_2(km_array,lt_array,0)
        #@second_graph_array=fill_katanalwsh_array(consumption_array,0)
        @second_graph_array=new_katanalwsh_array(consumption_array,0)
        #puts consumption_array
        #puts '--------------------'
        #puts @katanalwsh_pinakas
        puts @second_graph_array


        @second_graph_array=@second_graph_array.to_json.html_safe
        @array_date=@array_date.uniq
        @array_date=@array_date.to_json.html_safe
        @date_pinakas=@date_pinakas.to_json.html_safe
        #puts @date_pinakas
      elsif((xronos.include?("all"))&&(!oxhma.include?("none"))&&(sugkrish)&&(!array[5].include?("none")))
        #SYGKRISH 2 OXHMATWN oxhma kai second_vehicle GIA SUGKEKRIMENO STA8MO
        @case=3
        second_vehicle=array[5]
        @station_id=Station.find_by_id(station)
        #check if user owns second_vehicle
        flag_different_user=false
        @vehicle=Array.new
        @vehicle=Vehicle.where(station_id: @station_id.id).where(brand: oxhma).where(fuel_type:fuel_type).order(:fuel_date)#.or(Vehicle.where(station_id: @station_id.id).where(brand:second_vehicle).order(:fuel_date))
        puts @vehicle.inspect
        #2 ksexwristes erwthseis sth bash...gia omadopoihsh twn dedomenwn 
        km_array=Array.new
        lt_array=Array.new
        @array_date=Array.new
        @user_id=Array.new
        @vehicle_list=Array.new
        consumption_array=Array.new
        km_array2=Array.new
        lt_array2=Array.new
        @timh_pinakas=Array.new
        @prathria_list=Array.new
        @katanalwsh_pinakas=Array.new
        @date_pinakas=Array.new
        @oxhmata=Array.new
        @graph_date=Array.new
        @katanalwsh_pinakas2=Array.new
        @second_graph=Array.new
        if(@vehicle.size>2)
          
          @vehicle.each do|vehicle|
              if(!@oxhmata.include?(vehicle.name))
                @oxhmata.insert(-1,vehicle.name)
              end
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array2.insert(-1,vehicle.kilometers)
              lt_array2.insert(-1,vehicle.liters)
          end
          consumption_array=find_consumption_2(km_array2,lt_array2,0)
          puts consumption_array
          @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,0)
          puts @katanalwsh_pinakas
          @graph_date=@array_date.uniq
          @vehicle_list.clear
          @array_date.clear
          @user_id.clear
          @oxhmata.clear
          km_array2.clear
          lt_array2.clear
          consumption_array.clear
        end

        second_array=Vehicle.where(station_id: @station_id.id).where(brand:second_vehicle).order(:fuel_date)
        if(@vehicle.size>2)
          second_array.each do|vehicle|
            if(!@oxhmata.include?(vehicle.name))
              @oxhmata.insert(-1,vehicle.name)
            end
            @vehicle_list.insert(-1,vehicle.name)
            @array_date.insert(-1,vehicle.fuel_date)
            @user_id.insert(-1,vehicle.user_id)
            km_array2.insert(-1,vehicle.kilometers)
            lt_array2.insert(-1,vehicle.liters)
          end
          consumption_array=find_consumption_2(km_array2,lt_array2,0)
          puts consumption_array
          @katanalwsh_pinakas2=new_katanalwsh_array(consumption_array,0)
          #afairesh diploeggrafwn tou pinaka
          @second_graph=@array_date.uniq
          puts @katanalwsh_pinakas
        end
        @first_brand=oxhma
        @second_brand=second_vehicle
        @first_brand=@first_brand.to_json.html_safe
        @second_brand=@second_brand.to_json.html_safe
        @graph_date=@graph_date.to_json.html_safe
        @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
        @katanalwsh_pinakas2=@katanalwsh_pinakas2.to_json.html_safe
        @second_graph=@second_graph.to_json.html_safe


      elsif ((xronos.include?("all"))&&(!oxhma.include?("none")))
        # upologizw kai gia ton xrhsth sto sugkekrimeno prathrio to sugkekrimeno oxhma me tupo kausimou
        @case=4
        @station_id=Station.find_by_id(station)
        #an 8elw o xrhsths na epilegei ton mhna pou 8elei na dei gia sugkekrimeno prathrio   
        #@vehicle=Vehicle.where(station_id: station_id).where(name: oxhma).where(fuel_type:fuel_type).where(user_id: current_user).where('extract(month from fuel_date) = ?', xronos).order(:fuel_date)
        @vehicle=Vehicle.where(station_id: @station_id.id).where(name: oxhma).where(fuel_type:fuel_type).where(user_id: current_user).order(:fuel_date)
        puts @vehicle.inspect
        puts @vehicle.size
        litra=0.0
        km=0.0
        km_array=Array.new
        lt_array=Array.new
        @array_date=Array.new
        @user_id=Array.new
        @vehicle_list=Array.new
        consumption_array=Array.new
        @litra_pinakas=Array.new
        @timh_pinakas=Array.new
        @prathria_list=Array.new
        if(@vehicle.size>1)
            @katanalwsh_pinakas=Array.new
            @date_pinakas=Array.new
            puts @katanalwsh_pinakas
            puts "hmeromhnia.."
            puts @date_pinakas
            last_km=@vehicle.last.kilometers.to_f
            first_km=@vehicle.first.kilometers.to_f
            km=last_km-first_km
             puts "REEEEEEEEEEEEEEEEEE #{km}"
            counter=0
            @vehicle.each do|vehicle|
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array.insert(-1,vehicle.kilometers)
              lt_array.insert(-1,vehicle.liters)
              @timh_pinakas.insert(-1,vehicle.price)
              @prathria_list.insert(-1,vehicle.station_id)
              counter+=1 
              if(counter<@vehicle.count)
                litra+=vehicle.liters
              end
            end
            puts "REEEEEEEEEEEEEEEEEE #{litra}"
            @katanalwsh_xronou=100*litra/km
            @katanalwsh_xronou=@katanalwsh_xronou.round(3)
          consumption_array=find_consumption_2(km_array,lt_array,0)
          puts consumption_array
          puts @case
          #@katanalwsh_pinakas=fill_katanalwsh_array(consumption_array,0)
          @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,0)
          puts "--------------------------------"
          puts @katanalwsh_pinakas
          @km_graph=Array.new
          for i in 0..km_array.size-1 
            if(i!=km_array.size-1)
              @km_graph.insert(-1,km_array[i+1]-km_array[i])
            end
          end
          @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
          @date_pinakas=@array_date
          @litra_pinakas=lt_array
          @date_pinakas=@date_pinakas.to_json.html_safe
          @prathria_uniq_list=@prathria_list.uniq
        else
          @error_message='DEN YPARXEI H EGGRAFH TOY OXHMATOS '+ oxhma+' STO PRATHRIO ' +station+' TON MHNA '+ xronos+' ME AYTO TON TYPO KAYSIMOU ' +fuel_type
          puts "DEN YPARXEI H EGGRAFH TOY OXHMATOS #{oxhma} STO PRATHRIO #{station} TON MHNA #{xronos}ME AYTO TON TYPO KAYSIMOU #{fuel_type}" 
        end
      else
        @error_message='Λάθος Κριτήρια Αναζήτησης'
        puts "la8os krithria anazhthshs"
        
      end
    end
    
    
    
    
    #NA PARW TA PARAMS GIA KATHE STATION KSEXWRISTA 
  end


  def contact
    @my_station=params[:my_station]
    @fuel_type=params[:fuel_type]
    @stations_ids=Array.new
    @name_station=Station.find_by_id(@my_station).name
    @prathrio=Array.new
    @geograph_area=Array.new
    @company_selector=Array.new
    @array_date= Array.new
    @oxhmata=Array.new
    @vehicle_list=Array.new
    @user_id=Array.new
    km_array=Array.new
    lt_array=Array.new
    @graph_date=Array.new
    @message=-1
    @flag_JS=0
    @first_name=-1
    @second_name=-1
    @title_graph=-1
    @title_graph2=-1
   # @type=
    #an o xrhsths epileksei  statistika tou sta8mou
    if(!params[:fuel_type].nil?)
      @flag_JS=1
      puts "SECOND STATION #{params[:second_station]}"
      #tou dinw station_id sto my_station
      puts "MY_STATION #{@my_station}"
      
     
      @second_vehicle=Array.new
      @katanalwsh_pinakas2=Array.new
      @second_graph=Array.new
      km_array2=Array.new
      lt_array2=Array.new
      second_station=params[:second_station]

      if(second_station.nil?)
        #gemizw to select sto html

        temp_collection=Vehicle.where.not(station_id: @my_station).pluck(:station_id).uniq
        temp_collection.each do|vehicle|
          @stations_ids.insert(0,vehicle)
          @prathrio.insert(0,Station.find_by_id(vehicle).name)
        end
        @prathrio.insert(0," ")
        @stations_ids.insert(0," ")
        puts @stations_ids,@prathrio
        @prathrio=@prathrio.to_json.html_safe
        @stations_ids=@stations_ids.to_json.html_safe
      else
        puts "EDWWWWWWWWWWWWWWWW SIZE  #{second_station.size}"
        if(second_station.size>1)
          #station_id=Station.where(name:second_station).first.id
          #getting id from params of second_station
          @second_vehicle=Vehicle.where(station_id: second_station).where(fuel_type: @fuel_type).order(:fuel_date)
          if(@second_vehicle.size>1)
            @second_vehicle.each do|vehicle|
              if(!@oxhmata.include?(vehicle.name))
                @oxhmata.insert(-1,vehicle.name)
              end
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array2.insert(-1,vehicle.kilometers)
              lt_array2.insert(-1,vehicle.liters)
            end

            consumption_array=find_consumption_2(km_array2,lt_array2,0)
            puts consumption_array
            
            #@katanalwsh_pinakas2=fill_katanalwsh_array(consumption_array,0)
            @katanalwsh_pinakas2=new_katanalwsh_array(consumption_array,0)
            #afairesh diploeggrafwn tou pinaka
            @second_graph=@array_date.uniq
            puts "pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp"
            puts @second_graph
            #puts "katanalwsh_pinakas"
            puts "pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp"
            puts @katanalwsh_pinakas2
            #puts @graph_date
            #puts @katanalwsh
            @vehicle_list.clear
            @array_date.clear
            @user_id.clear
            @oxhmata.clear
            @second_graph=@second_graph.to_json.html_safe
            @katanalwsh_pinakas2=@katanalwsh_pinakas2.to_json.html_safe
            #@vehicle_list=@vehicle_list.to_json.html_safe
            #@oxhmata=@oxhmata.to_json.html_safe
            @second_name=Station.find_by_id(second_station).name
            @second_name=@second_name.to_json.html_safe
            @title_graph2="Σύγκριση μέσης κατανάλωσης οχημάτων στα δύο πρατήρια για καύσιμο #{params[:fuel_type]}"
            @title_graph2=@title_graph2.to_json.html_safe
            respond_to do |format|
              format.js
            end
          else
            @message="Δεν υπάρχουν εγγραφές στο σύστημα για το δευτερο πρατήριο"
            puts @message

            @message=@message.to_json.html_safe
            respond_to do |format|
              format.js
            end
          end
        end
      end

      @vehicle=Vehicle.where(station_id: @my_station).where(fuel_type: @fuel_type).order(:fuel_date)
      puts @vehicle.size

      if(@vehicle.size!=0)

        @message=0
        @vehicle.each do|vehicle|
          if(!@oxhmata.include?(vehicle.name))
            @oxhmata.insert(-1,vehicle.name)
          end
          @vehicle_list.insert(-1,vehicle.name)
          @array_date.insert(-1,vehicle.fuel_date)
          @user_id.insert(-1,vehicle.user_id)
          km_array.insert(-1,vehicle.kilometers)
          lt_array.insert(-1,vehicle.liters)
        end

        @katanalwsh_pinakas=Array.new
        for i in 0..@vehicle_list.size-1
            puts "#{@vehicle_list[i]} #{@array_date[i]} #{@user_id[i]}"
        end
        puts "diafora"
        first_date=-1
        second_date=-1
        counter=0

        puts counter,first_date,second_date
        consumption_array=Array.new

        consumption_array=find_consumption_2(km_array,lt_array,0)
        puts consumption_array
        
        #@katanalwsh_pinakas=fill_katanalwsh_array(consumption_array,0)
        @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,0)
        #afairesh diploeggrafwn tou pinaka
        @graph_date=@array_date.uniq

        puts @katanalwsh_pinakas

        @graph_date=@graph_date.to_json.html_safe
        @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
        @vehicle_list=@vehicle_list.to_json.html_safe
        @oxhmata=@oxhmata.to_json.html_safe
        @first_name=@name_station
        @first_name=@first_name.to_json.html_safe
        @title_graph="Mέση κατανάλωση οχημάτων πρατηρίου #{@name_station} για καύσιμο #{params[:fuel_type]}"
        @title_graph=@title_graph.to_json.html_safe
        respond_to do |format|
          format.js
        end

      else

        @message="Δεν υπάρχουν εγγραφές στο σύστημα για το πρατήριο αυτο"
        puts @message
        @graph_date=@graph_date.to_json.html_safe
        @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
        @vehicle_list=@vehicle_list.to_json.html_safe
        @oxhmata=@oxhmata.to_json.html_safe
        @first_name=@name_station
        @first_name=@first_name.to_json.html_safe
        @message=@message.to_json.html_safe
        respond_to do |format|
          format.js
        end
      end  
    end 
    #an o xrhsths epileksei gewgrafika statistika
    if(!params[:fuel_area].nil?)
      fuel_area=params[:fuel_area]
      @second_vehicle=Array.new
      @katanalwsh_pinakas2=Array.new
      @second_graph=Array.new
      km_array2=Array.new
      lt_array2=Array.new
      first_area=Station.find_by_id(@my_station).area
      second_area=params[:second_area]
      @flag_JS=2
      if(second_area.nil?)
        #fill second_area_selector html
        
        temp_collection=Vehicle.where.not(area: first_area)
        temp_collection.each do|vehicle| 
          if(!@geograph_area.include?(vehicle.area))
            @geograph_area.insert(0,vehicle.area)
          end
        end
        puts @geograph_area
        
        @geograph_area.insert(0," ")
        
        @geograph_area=@geograph_area.to_json.html_safe
      else
        if(second_area.size>1)
          
          #puts station_id
          @vehicle=Vehicle.where(area: second_area).where(fuel_type: fuel_area).order(:fuel_date)
          puts @second_vehicle.inspect
          if(@vehicle.size>1)
            @vehicle.each do|vehicle|
              if(!@oxhmata.include?(vehicle.name))
                @oxhmata.insert(-1,vehicle.name)
              end
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array2.insert(-1,vehicle.kilometers)
              lt_array2.insert(-1,vehicle.liters)
            end

            consumption_array=find_consumption_2(km_array2,lt_array2,"station")
            puts consumption_array
            
            #@katanalwsh_pinakas2=fill_katanalwsh_array(consumption_array,"station")
            @katanalwsh_pinakas2=new_katanalwsh_array(consumption_array,"station")
            #afairesh diploeggrafwn tou pinaka
            @second_graph=@array_date.uniq
            puts "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
            puts @second_graph
            #puts "katanalwsh_pinakas"
            puts "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr"
            puts @katanalwsh_pinakas2
            #puts @graph_date
            #puts @katanalwsh
            @vehicle_list.clear
            @array_date.clear
            @user_id.clear
            @oxhmata.clear
            @second_graph=@second_graph.to_json.html_safe
            @katanalwsh_pinakas2=@katanalwsh_pinakas2.to_json.html_safe
            @second_name=second_area
            @second_name=@second_name.to_json.html_safe
            @title_graph2="Σύγκριση μέσης κατανάλωσης οχημάτων των δύο περιοχών για καύσιμο #{params[:fuel_area]}"
            @title_graph2=@title_graph2.to_json.html_safe
            respond_to do |format|
              format.js
            end
          else
            @message="Δεν υπάρχουν εγγραφές στο σύστημα για τη δεύτερη γεωγραφικη περιοχη"
            puts @message

            @message=@message.to_json.html_safe
            respond_to do |format|
              format.js
            end
          end
        end

      end
        
       #briskw apo to my_station thn perioxh thn opoia einai to sugkekrimeno prathrio
        area=Station.find_by_id(params[:my_station]).area
        @vehicle=Vehicle.where(area: area).where(fuel_type: fuel_area).order(:fuel_date)
        if(@vehicle.size>1)
          @vehicle.each do|vehicle|
            if(!@oxhmata.include?(vehicle.name))
              @oxhmata.insert(-1,vehicle.name)
            end
            @vehicle_list.insert(-1,vehicle.name)
            @array_date.insert(-1,vehicle.fuel_date)
            @user_id.insert(-1,vehicle.user_id)
            km_array.insert(-1,vehicle.kilometers)
            lt_array.insert(-1,vehicle.liters)
          end
          @katanalwsh_pinakas=Array.new
          consumption_array=Array.new
          consumption_array=find_consumption_2(km_array,lt_array,"station")
          puts consumption_array
          #@katanalwsh_pinakas=fill_katanalwsh_array(consumption_array,"station")
          @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,"station")
          puts @katanalwsh_pinakas
          @graph_date=@array_date.uniq
          puts @graph_date
          @graph_date=@graph_date.to_json.html_safe
          @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
          @vehicle_list=@vehicle_list.to_json.html_safe
          @oxhmata=@oxhmata.to_json.html_safe
          @first_name=area
          @first_name=@first_name.to_json.html_safe
          @title_graph="Mέση κατανάλωση οχημάτων περιοχής #{@first_name} για καύσιμο #{params[:fuel_area]}"
          @title_graph=@title_graph.to_json.html_safe
          respond_to do |format|
            format.js
          end
        else
          @graph_date=@graph_date.to_json.html_safe
          @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
          @vehicle_list=@vehicle_list.to_json.html_safe
          @oxhmata=@oxhmata.to_json.html_safe
          @first_name=area
          @first_name=@first_name.to_json.html_safe
          @message="Δεν υπάρχουν εγγραφές στο σύστημα για τo καύσιμο #{params[:fuel_area]}"
            puts @message

            @message=@message.to_json.html_safe
            respond_to do |format|
              format.js
            end
        end
      
    end
    #an o xrhsths epileksei marka kausimou
    if(!params[:fuel_company].nil?)
      fuel=params[:fuel_company]
      @second_vehicle=Array.new
      @katanalwsh_pinakas2=Array.new
      @second_graph=Array.new
      km_array2=Array.new
      lt_array2=Array.new
      @flag_JS=3
      station_id=Station.find_by_id(params[:my_station])
      area=station_id.area
      first_company=station_id.company
      #second company selector
      second_company=params[:second_company]
      if(second_company.nil?)
        #fill second_company selector html
        temp_collection=Station.where(area: area).where.not(company: first_company)
        temp_collection.each do|station| 
          if(!@company_selector.include?(station.company))
            @company_selector.insert(0,station.company)
          end
        end
        @company_selector.insert(0," ")
        puts "EEEEEEEEEEEEEEE #{@company_selector}"
        @prathrio=@prathrio.to_json.html_safe
        @geograph_area=@geograph_area.to_json.html_safe
        @company_selector=@company_selector.to_json.html_safe
      else
        if(second_company.size>1)
          stations=Station.where(area: area).where(company:second_company).ids
          @vehicle=Vehicle.where(area: area).where(station_id: stations).where(fuel_type: fuel).order(:fuel_date)
          if(@vehicle.size>1)
            @vehicle.each do|vehicle|
              if(!@oxhmata.include?(vehicle.name))
                @oxhmata.insert(-1,vehicle.name)
              end
              @vehicle_list.insert(-1,vehicle.name)
              @array_date.insert(-1,vehicle.fuel_date)
              @user_id.insert(-1,vehicle.user_id)
              km_array2.insert(-1,vehicle.kilometers)
              lt_array2.insert(-1,vehicle.liters)
            end

            consumption_array=find_consumption_2(km_array2,lt_array2,"station")
            puts consumption_array
            
            #@katanalwsh_pinakas2=fill_katanalwsh_array(consumption_array,"station")
            @katanalwsh_pinakas2=new_katanalwsh_array(consumption_array,"station")
            #afairesh diploeggrafwn tou pinaka
            @second_graph=@array_date.uniq
            puts "sssssssssssssssssssssssssssssssssssssssssssssss"
            puts @second_graph
            #puts "katanalwsh_pinakas"
            puts "sssssssssssssssssssssssssssssssssssssssssssssss"
            puts @katanalwsh_pinakas2
            #puts @graph_date
            #puts @katanalwsh
            @vehicle_list.clear
            @array_date.clear
            @user_id.clear
            @oxhmata.clear
            @second_graph=@second_graph.to_json.html_safe
            @katanalwsh_pinakas2=@katanalwsh_pinakas2.to_json.html_safe
            @second_name=second_company
            @second_name=@second_name.to_json.html_safe
            @title_graph2="Σύγκριση μέσης κατανάλωσης οχημάτων των δύο εταιρειών για καύσιμο #{fuel}"
            @title_graph2=@title_graph2.to_json.html_safe
            respond_to do |format|
              format.js
            end
          else
            @message="Δεν υπάρχουν εγγραφές στο σύστημα για τη δεύτερη εταιρεία"
            puts @message

            @message=@message.to_json.html_safe
            respond_to do |format|
              format.js
            end
          end
        end
      end




      stations=Station.where(area: area).where(company:first_company).ids

      @vehicle=Vehicle.where(station_id: stations).where(fuel_type: fuel).order(:fuel_date)

      if(@vehicle.size>1)
          @vehicle.each do|vehicle|
            if(!@oxhmata.include?(vehicle.name))
              @oxhmata.insert(-1,vehicle.name)
            end
            @vehicle_list.insert(-1,vehicle.name)
            @array_date.insert(-1,vehicle.fuel_date)
            @user_id.insert(-1,vehicle.user_id)
            km_array.insert(-1,vehicle.kilometers)
            lt_array.insert(-1,vehicle.liters)
          end
          @katanalwsh_pinakas=Array.new
          consumption_array=Array.new
          consumption_array=find_consumption_2(km_array,lt_array,"station")
          puts consumption_array
          #@katanalwsh_pinakas=fill_katanalwsh_array(consumption_array,"station")
          @katanalwsh_pinakas=new_katanalwsh_array(consumption_array,"station")
          puts @katanalwsh_pinakas
          @graph_date=@array_date.uniq
          puts @graph_date
          @graph_date=@graph_date.to_json.html_safe
          @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
          @vehicle_list=@vehicle_list.to_json.html_safe
          @oxhmata=@oxhmata.to_json.html_safe
          @first_name=first_company
          @first_name=@first_name.to_json.html_safe
          @title_graph="Mέση κατανάλωση οχημάτων εταιρείας #{@first_name} για καύσιμο #{fuel}"
          @title_graph=@title_graph.to_json.html_safe
          respond_to do |format|
            format.js
          end
      else
          @graph_date=@graph_date.to_json.html_safe
          @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
          @vehicle_list=@vehicle_list.to_json.html_safe
          @oxhmata=@oxhmata.to_json.html_safe
          @first_name=first_company
          @first_name=@first_name.to_json.html_safe
          @message="Δεν υπάρχουν εγγραφές στο σύστημα για τo καύσιμο #{fuel} στην εταιρεία #{@first_name}"
            puts @message

            @message=@message.to_json.html_safe
            respond_to do |format|
              format.js
            end
        end  
    end

  end


  protected

  def new_katanalwsh_array(consumption_array,flag_station)
    puts "-------------new katanalwsh-----------------"
    #create range interval tree

    temp_collection=Array.new
    range_tree =  RangeTree::Tree.new
    
    #parser=Date.strptime(consumption_array[0].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
    #puts parser.to_i
    if(flag_station!="station")
      i=0

      while (i<consumption_array.size)#mporei na 8elei kai -6 edw
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+5]
        i=i+6
      end
      if(i==0)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+5]
      end
      for i in 0..@array_date.size-1
        if(i!=@array_date.size-1&&@array_date[i]!=@array_date[i+1])
          first_date=Date.strptime(@array_date[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          last_date=Date.strptime(@array_date[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          first_date=first_date.to_i
          last_date=last_date.to_i
          range_query=range_tree[first_date..last_date]
          #range_query=range_query.uniq
          second_flag=false
          previous_consumption=0
          days=calc_day(i,i+1)
          sum_range_query=0
          puts "----------------------------------"
          puts "gia diasthma #{@array_date[i]} #{@array_date[i+1]} #{range_query}"
          for k in 0..range_query.size-1
            #custom method for finding the position of the array
            temp_pos=finding_index(range_query[k],consumption_array,flag_station,@array_date[i],@array_date[i+1])
            #temp_pos=consumption_array.find_index(range_query[k])
            date_temp_last=consumption_array[temp_pos-4]
            date_temp_first=consumption_array[temp_pos-5]
            puts "#{temp_pos} TO TEMP POS KAI #{date_temp_first} #{date_temp_last}"
            if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])
     
                #previous_consumption=previous_consumption+range_query[k]/consumption_array[temp_pos-1]
                #puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days}"
                previous_consumption=previous_consumption+range_query[k]
                sum_range_query+=1
                puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption}"              
                second_flag=true

              
            end
                   
          end
          if(second_flag==true)
              #puts "otan einai true #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days/sum_range_query}"
              #temp_collection.insert(-1,previous_consumption*days/sum_range_query)
              puts "otan einai true #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption/sum_range_query}"
              temp_collection.insert(-1,previous_consumption/sum_range_query)
          end
        end
      end
    else
      i=0
      while (i<consumption_array.size)#mporei -7 edw
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+6]
        i=i+7
      end
      if(i==0)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+6]
      end
      for i in 0..@array_date.size-1
        if(i!=@array_date.size-1&&@array_date[i]!=@array_date[i+1])
          first_date=Date.strptime(@array_date[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          last_date=Date.strptime(@array_date[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          first_date=first_date.to_i
          last_date=last_date.to_i
          range_query=range_tree[first_date..last_date]
          #range_query=range_query.uniq
          second_flag=false
          previous_consumption=0
          days=calc_day(i,i+1)
          sum_range_query=0
          puts "--------------station--------------"
          puts "gia diasthma #{@array_date[i]} #{@array_date[i+1]} #{range_query}"
          for k in 0..range_query.size-1
            #custom method for finding the position of the array
            temp_pos=finding_index(range_query[k],consumption_array,flag_station,@array_date[i],@array_date[i+1])
            #temp_pos=consumption_array.find_index(range_query[k])
            date_temp_last=consumption_array[temp_pos-5]
            date_temp_first=consumption_array[temp_pos-6]
            puts "#{temp_pos} TO TEMP POS KAI #{date_temp_first} #{date_temp_last}"
            if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])
                #previous_consumption=previous_consumption+range_query[k]/consumption_array[temp_pos-1]
                #puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days} meres pou exei kanei #{consumption_array[temp_pos-1]}"
                previous_consumption=previous_consumption+range_query[k]
                puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption} meres pou exei kanei #{consumption_array[temp_pos-1]}"
                sum_range_query+=1
                
                second_flag=true   
            end
                   
          end
          if(second_flag==true)
              #puts "otan einai true #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days/sum_range_query}"
              #temp_collection.insert(-1,previous_consumption*days/sum_range_query)
              puts "otan einai true #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption/sum_range_query}"
              temp_collection.insert(-1,previous_consumption/sum_range_query)
          end
        end
      end

    end
    return temp_collection
  end

  def finding_index(element,temp_array,temp_flag,first_date,last_date)
    position=0
    if(temp_flag!="station")
      (0..temp_array.size-6).step(6).each do |j|
        if(element==temp_array[j+5])
          if(temp_array[j+1]>=last_date&&temp_array[j]<=first_date)
            position=j+5
            puts "tttttttttttttttttto brhka"
            break
          else
            position=j+5
          end
        end
      end
    else
      (0..temp_array.size-7).step(7).each do |j|
        if(element==temp_array[j+6])
          if(temp_array[j+1]>=last_date&&temp_array[j]<=first_date)
            position=j+6
            puts "tttttttttttttttttto brhka"
            break
          else
            position=j+6
          end
        end
      end
    end
    return position
  end


  def fill_katanalwsh_array(consumption_array,flag_station)
    #create range interval tree

    temp_collection=Array.new
    range_tree =  RangeTree::Tree.new
    
    parser=Date.strptime(consumption_array[0].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
    puts parser.to_i
    if(flag_station!="station")
      i=0
      while (i<consumption_array.size-6)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+5]
        i=i+6
      end
      if(i==0)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+5]
      end              
      for i in 0..@array_date.size-1
      
        if(i!=@array_date.size-1&&@array_date[i]!=@array_date[i+1])
        
          first_date=Date.strptime(@array_date[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          last_date=Date.strptime(@array_date[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          first_date=first_date.to_i
          last_date=last_date.to_i
          range_query=range_tree[first_date..last_date]
            j=0
            flag=false
            puts "edw exoyme to size toy consumption #{consumption_array.size}"
            (0..consumption_array.size-6).step(6).each do |j|
              #puts "#{consumption_array[j]} #{@array_date[i]} #{consumption_array[j+1]} #{@array_date[i+1]}"
              if(consumption_array[j]==@array_date[i]&&consumption_array[j+1]==@array_date[i+1])
                temp_flag=false
                puts "1per #{@array_date[i]}  #{@array_date[i+1]}"
                first_consumption=consumption_array[j+5]
                position=range_query.find_index(first_consumption)
                puts "!!!!!first_consumption einai #{first_consumption}"
                puts "!!!!!position einai #{position}"
                if(!position.nil?)
                  puts "to range query einai #{range_query}"
                  range_query.delete_at(position)
                else
                  temp_flag=true
                  temp_collection.insert(-1,first_consumption)
                  flag=true
                end
                puts "to range query einai #{range_query}"

                #remove seconds
                range_query=range_query.uniq
                for k in 0..range_query.size-1
                  temp_pos=consumption_array.find_index(range_query[k])
                  date_temp_last=consumption_array[temp_pos-4]
                  date_temp_first=consumption_array[temp_pos-5]
                  puts "ieieieie #{date_temp_last} #{date_temp_first}"
                  if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])
                    puts "ta kanonika  #{@array_date[i]} #{@array_date[i+1]}"
                    days=calc_day(i,i+1)
                    previous_consumption=range_query[k]/consumption_array[temp_pos-1]
                    if(temp_flag==true)
                      temp_collection.delete_at(-1)
                      temp_collection.insert(-1,previous_consumption*days+first_consumption)
                    else
                      temp_collection.insert(-1,previous_consumption*days+first_consumption)
                    end
                    
                    puts previous_consumption*days+first_consumption
                    flag=true
                  end
                  if(k==range_query.size-1&&flag==false)
                    
                      puts "-----------KALHSPERA #{@array_date[i]} #{@array_date[i+1]}"
                      temp_collection.insert(-1,first_consumption)
                      flag=true 
                  end  
                end
                if(range_query.size==0&&flag==false)
                  flag=true
                  temp_collection.insert(-1,first_consumption)
                end
              end
            end

          if(flag==false)
              puts "2per #{@array_date[i]} #{@array_date[i+1]}"
              puts "to range query einai #{range_query}"
              second_flag=false
              previous_consumption=0
              range_query=range_query.uniq
              days=calc_day(i,i+1)
              sum_range_query=0
              for k in 0..range_query.size-1
                temp_pos=consumption_array.find_index(range_query[k])
                date_temp_last=consumption_array[temp_pos-4]
                date_temp_first=consumption_array[temp_pos-5]
                puts "#{temp_pos} TO TEMP POS "
                if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])
                  
                  previous_consumption=previous_consumption+range_query[k]/consumption_array[temp_pos-1]
                  sum_range_query+=1
                  puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days}"
                  second_flag=true
                end
                
              end
              if(second_flag==true)
                 puts "otan einai true #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days/sum_range_query}"
                temp_collection.insert(-1,previous_consumption*days/sum_range_query)
              end 
              
              if(@vehicle_list[i]!=@vehicle_list[i+1]&&@user_id[i]!=@user_id[i+1])
                puts "AAAAAAAAAAAA  #{@array_date[i]} #{@array_date[i+1]}"
                temp_collection.insert(-1,-1)
              elsif ((@vehicle_list[i]!=@vehicle_list[i+1]&&@user_id[i]==@user_id[i+1]))
                puts "DEN EINAI IDIA OXHMATA  #{@array_date[i]} #{@array_date[i+1]}"
                temp_collection.insert(-1,-1)
              end
            end
          end
      end
    else
      #-------------------------------------------------------------------
      #if flag_station==station
      puts flag_station
      i=0
      while (i<consumption_array.size-7)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+6]
        i=i+7
      end
      if(i==0)
        first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
        range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+6]
      end
      station_array=Array.new
      @vehicle.each do|vehicle|
        station_array.insert(-1,vehicle.station_id)
      end
      for i in 0..@array_date.size-1
      
        if(i!=@array_date.size-1&&@array_date[i]!=@array_date[i+1])
        
          first_date=Date.strptime(@array_date[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          last_date=Date.strptime(@array_date[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
          first_date=first_date.to_i
          last_date=last_date.to_i
          range_query=range_tree[first_date..last_date]
            j=0
            flag=false
            puts "edw exoyme to size toy consumption #{consumption_array.size}"
            (0..consumption_array.size-7).step(7).each do |j|
              #puts "#{consumption_array[j]} #{@array_date[i]} #{consumption_array[j+1]} #{@array_date[i+1]}"
              if(consumption_array[j]==@array_date[i]&&consumption_array[j+1]==@array_date[i+1])
                temp_flag=false
                puts "#{@array_date[i]}  #{@array_date[i+1]}"
                first_consumption=consumption_array[j+6]
                position=range_query.find_index(first_consumption)
                puts "!!!!!first_consumption einai #{first_consumption}"
                puts "!!!!!position einai #{position}"
                if(!position.nil?)
                  puts "NOT NIL to range query einai #{range_query}"
                  range_query.delete_at(position)
                else
                  puts "NIL"
                  temp_flag=true
                  temp_collection.insert(-1,first_consumption)
                  flag=true
                end
                puts "to range query einai #{range_query}"

                #remove seconds
                range_query=range_query.uniq
                counter_consumption_station=0
                different_stations=false
                for k in 0..range_query.size-1
                  temp_pos=consumption_array.find_index(range_query[k])
                  date_temp_last=consumption_array[temp_pos-5]
                  date_temp_first=consumption_array[temp_pos-6]
                  
                  if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])
                    puts "ta kanonika  #{@array_date[i]} #{@array_date[i+1] } #{range_query[k]}"
                    days=calc_day(i,i+1)
                    previous_consumption=range_query[k]/consumption_array[temp_pos-1]
                    if(temp_flag==true)
                      temp_collection.delete_at(-1)
                      temp_collection.insert(-1,previous_consumption*days+first_consumption)
                      
                    #else
                      #temp_collection.insert(-1,previous_consumption*days+first_consumption)
                    end
                    if(consumption_array[temp_pos-2]!=consumption_array[position-2])
                      #an einai diaforetikoi sta8moi tou epilegomenou me tou arxikou
                      
                      temp_cons=days*range_query[k]/consumption_array[temp_pos-1]
                      counter_consumption_station+=temp_cons
                      #puts "DIAFORETIKOI STA8MOI #{counter_consumption_station}"
                      different_stations=true
                    end
                    #puts previous_consumption*days+first_consumption
                    flag=true
                  end
                  if(k==range_query.size-1&&flag==false)
                    
                      puts "KALHSPERA #{@array_date[i]} #{@array_date[i+1]}"
                      temp_collection.insert(-1,first_consumption)
                      flag=true 
                      temp_flag=true
                  end  
                end
                if(range_query.size==0&&flag==false)
                  flag=true
                  #temp_collection.insert(-1,first_consumption)
                end
                if(different_stations=true&&temp_flag==false)

                  puts "DIFFERENT STATIONS #{counter_consumption_station+first_consumption}"
                  temp_collection.insert(-1,counter_consumption_station+first_consumption)
                  
                end
              end
            end

          if(flag==false)
              puts "#{@array_date[i]} #{@array_date[i+1]}"
              puts "to range query einai #{range_query}"
              second_flag=false
              previous_consumption=0
              range_query=range_query.uniq
              for k in 0..range_query.size-1
                temp_pos=consumption_array.find_index(range_query[k])
                date_temp_last=consumption_array[temp_pos-5]
                date_temp_first=consumption_array[temp_pos-6]
                puts "#{temp_pos} TO TEMP POS "
                if(date_temp_last>=@array_date[i+1]&&date_temp_first<=@array_date[i])

                  days=calc_day(i,i+1)
                  previous_consumption=previous_consumption+range_query[k]/consumption_array[temp_pos-1]
                  
                  puts "deuterh periptwsh #{@array_date[i]} #{@array_date[i+1]} kai #{previous_consumption*days}"
                  second_flag=true
                end
                
              end
              if(second_flag==true)
                temp_collection.insert(-1,previous_consumption*days)
              end 
              
              if(@vehicle_list[i]!=@vehicle_list[i+1]&&@user_id[i]!=@user_id[i+1])
                puts "AAAAAAAAAAAA  #{@array_date[i]} #{@array_date[i+1]}"
                temp_collection.insert(-1,-1)
              elsif ((@vehicle_list[i]!=@vehicle_list[i+1]&&@user_id[i]==@user_id[i+1]))
                puts "DEN EINAI IDIA OXHMATA  #{@array_date[i]} #{@array_date[i+1]}"
                temp_collection.insert(-1,-1)
              end
            end
          end
      end


    end
    return temp_collection
  end

  def calc_day(position_first,position_second)
    mhnes=Array[0,31,28,31,30,31,30,31,31,30,31,30,31]
    first_month=@array_date[position_first].strftime("%m").to_i
    second_month=@array_date[position_second].strftime("%m").to_i
    first_day=@array_date[position_first].strftime("%d").to_i
    second_day=@array_date[position_second].strftime("%d").to_i
    first_year=@array_date[position_first].strftime("%y").to_i
    second_year=@array_date[position_second].strftime("%y").to_i
    days=0
    if(first_year==second_year)
      if(first_month == second_month)
        days=second_day-first_day
      else
        days=mhnes[first_month]-first_day
        #puts "arxikes meres, #{days}"
        for i in first_month+1..second_month
          
          if(i==second_month)
            days=days+second_day
            #puts "mphka"
            #puts "epomenes meres, #{days}"
          else
            days=days+mhnes[i]
            #puts "mphka2"
          end
        end
      end
    else
      puts "diaforetikos xronos"
      if(first_month == 12&& second_month==1)
        days=mhnes[first_month]-first_day+second_day
      end
    end
    #puts "edw einai h diafora tou #{first_month}-#{second_month} , #{days}"
    return days
  end


  def find_consumption_2(km_array,lt_array,flag)

    temp_array=Array.new
    #temp_collection=Vehicle.where(user_id: @user_id[i])
    station_array=Array.new
    #an einai to flag gia to diaforetiko station bres to kai kane enan elegxo mesa sto
    if(flag=="station")
      @vehicle.each do|vehicle|
        station_array.insert(-1,vehicle.station_id)
      end
    end

    for i in 0..@array_date.size-1
      start_date=i
      j=start_date+1
      
      while(j<@array_date.size)
        if(flag=="station")
          if(@vehicle_list[start_date]==@vehicle_list[j] && @user_id[start_date]==@user_id[j]&& station_array[start_date]==station_array[j])
            temp_array.insert(-1,@array_date[start_date])
            temp_array.insert(-1,@array_date[j])
            temp_array.insert(-1,@vehicle_list[j])
            temp_array.insert(-1,@user_id[j].to_s)
            temp_array.insert(-1,station_array[j].to_s)
            days=calc_day(i,j)
            temp_array.insert(-1,days)
            consumption=100*lt_array[start_date]/(km_array[j]-km_array[start_date])
            temp_array.insert(-1,consumption)
            j=@array_date.size
          else
            j=j+1
          end
        else
          if(@vehicle_list[start_date]==@vehicle_list[j] && @user_id[start_date]==@user_id[j])
            #start date
            #puts "start_date #{@array_date[start_date] }"
            temp_array.insert(-1,@array_date[start_date])
            #finish_date
            #puts "finish_date #{@array_date[j] }"
            temp_array.insert(-1,@array_date[j])
            #vehicle_name
            #puts "vehicle #{@vehicle_list[j] }"
            temp_array.insert(-1,@vehicle_list[j])
            #user_id
            #puts "user #{@user_id[j] }"
            temp_array.insert(-1,@user_id[j].to_s)
            #diasthma se hmeres
            days=calc_day(i,j)
            #puts "days #{days }"
            temp_array.insert(-1,days)
            #katanalwsh gia diasthma
            consumption=100*lt_array[start_date]/(km_array[j]-km_array[start_date])
            #puts "katanalwsh diasthmatos #{consumption }"
            temp_array.insert(-1,consumption)
            j=@array_date.size
            #puts "-------------------------"
          else
            j=j+1
          end
        end
      end
    end
    return temp_array
    #i=0
    #@vehicle.each do|vehicle|
    #  for i in 0..@array_date.size-1
    #    if(vehicle.user_id==user_id[i]&&vehicle.name==vehicle_list[i])
#
    #    end
    #  end
    #end
  end

  

  def ipRequest()
    url=URI.parse('http://api.ipstack.com/195.130.121.45?access_key=d7bdcffd598637070309c1c64b87806c')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    puts res.body.class
    return res.body
  end

  #Ypologizei xiliometra kai litra gia sugkekrimeno mhna
  def calculating(xronos)
      litra=0
      counter=0
      xronos=xronos.to_i
      km_temp=Array.new
      katanalwsh_mhna=0.0
      @vehicle.each do|vehicle| 
        if(vehicle.fuel_date.month==xronos)
          counter+=1  
        end
      end
      i=0
      @vehicle.each do|vehicle| #oxi swstos o counter
        if((vehicle.fuel_date.month==xronos)&&(i<=counter))

          i+=1
          km_temp.insert(-1,vehicle.kilometers) 
          if(i<counter)
            litra+=vehicle.liters
          end
        end
      end
      if(counter!=0)
        last_km=km_temp.last
        first_km=km_temp.first
        km=last_km-first_km
        if(km!=0.0)
          katanalwsh_mhna=100*litra/km
        end
      end
      return katanalwsh_mhna.round(3)
  end
#ypologismos katanalwshs gia ka8e neo gemisma
  def monthly_calc(xronos,temp_collection)
    km_temp=Array.new
    katanalwsh_mhna=Array.new
    lt_temp=Array.new
    date_temp=Array.new
    temp_collection.each do|vehicle|
      km_temp.insert(-1,vehicle.kilometers)
      lt_temp.insert(-1,vehicle.liters)
      date_temp.insert(-1,vehicle.fuel_date).to_s
    end
    liters=0
    for i in 0..km_temp.size-1
      #change formation of date from Y m d to m d Y
      date_temp[i]=date_temp[i].strftime("%m %d %Y")
      liters=0
      if(i<km_temp.size-1)
        
        kiliometers=km_temp[i+1]-km_temp[i]
        liters+=lt_temp[i]
        katanalwsh_mhna[i]=(liters/kiliometers)
        katanalwsh_mhna[i]=katanalwsh_mhna[i]*100
      end
      
    end

    katanalwsh_mhna.insert(0,0)
    return katanalwsh_mhna,date_temp
  end

  def find_period(start,first_date,second_date,counter)
    for i in start..@vehicle.size-1
      if(@vehicle[i].user_id==@user_id[i]&&@vehicle[i].name==@vehicle_list[i])
        #krata thn 8esh ths hmeromhnias kai psakse gia thn deyterh
        first_date=i
        username=@user_id[i]
        for j in i+1..@vehicle.size-1
          if(@vehicle[j].user_id==username&&@vehicle[j].name==@vehicle_list[j])
            second_date=j
            break
          else
            #pros8ese poses diaforetikes eggrafes briskontai sto diasthma mexri na brei
            counter+=1
            second_date=first_date
          end
        end
        #puts Vehicle.where('fuel_date BETWEEN ? AND ?', @array_date[first_date], @array_date[second_date]).where.not(user_id: username)
        break
      end
    end
    return first_date,second_date,counter
  end

  def calc_period(first,last)
    puts "DDDDDDDDDDDDDEXTHKA TO #{first} KAI TO #{last}"
    temp=@vehicle.where('fuel_date BETWEEN ? AND ?', first, last)

    user_list=Array.new
    oxhmata_list=Array.new
    temp.each do|vehicle| 
      if(!user_list.include?(vehicle.user_id))
        user_list.insert(0,vehicle.user_id)
      end
      if(!oxhmata_list.include?(vehicle.name))
        oxhmata_list.insert(0,vehicle.name)
      end
    end

    katanalwsh_pinakas=Array.new
    litra=Array.new(user_list)
    km=Array.new(user_list)
    last_km=Array.new(user_list)
    lt_per_km_monthly=Array.new(user_list)
    size_of_list=0
    if(user_list.size>oxhmata_list.size)
      size_of_list=user_list.size
    else
      size_of_list=oxhmata_list.size
    end
    puts "EEEEEEEEEEEEEEEEEEEEEEE #{temp.size}"
    for i in 0..size_of_list-1
      litra[i]=0
      if(oxhmata_list.size>=2)
        last_km[i]=temp.where(user_id: user_list[i]).where(name: oxhmata_list[i]).last.kilometers
        km[i]=last_km[i]-temp.where(user_id: user_list[i]).where(name: oxhmata_list[i]).first.kilometers 
      else
        last_km[i]=temp.where(user_id: user_list[i]).where(name: oxhmata_list[0]).last.kilometers
        km[i]=last_km[i]-temp.where(user_id: user_list[i]).where(name: oxhmata_list[0]).first.kilometers
      end
    end
    puts "EEEEEEEEEEEEEEEEEEEEEEE #{km}"
    temp.each do|vehicle|
      for i in 0..size_of_list-1
        if(user_list[i]==vehicle.user_id)
          if(last_km[i]!=vehicle.kilometers)
            litra[i]=litra[i]+vehicle.liters
          end
        end
      end
    end
    sum_km=0
    sum_liters=0
    for i in 0..size_of_list-1
      sum_km+=km[i]
      sum_liters+=litra[i]
    end
      puts litra,km
     katanalwsh=0
    katanalwsh=100*(sum_liters/sum_km)
    return katanalwsh
  end

end