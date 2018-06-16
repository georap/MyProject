class PagesController < ApplicationController
	#IP panepisthmiou 195.130.121.45 ----> request.location

	require 'freegeoip'
  def home
    @user_auth=false
    if (current_user.is_a?(GuestUser))
      @user_auth=false
    else
      @user_auth=true
    end
  	@ip=Freegeoip.get('195.130.121.45')
  	@addresses=Array.new
  	@station_items=Station.all
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
    @vehicle=Vehicle.where(user_id: current_user.id)
    @oxhmata=Array.new
    @mhnes=Array.new
    @stations=Array.new
    @vehicle.each do|vehicle| 
      if(!@oxhmata.include?(vehicle.name))
        @oxhmata.insert(0,vehicle.name)
      end
      if(!@mhnes.include?(vehicle.fuel_date.month))
        @mhnes.insert(0,vehicle.fuel_date.month)
      end
      #if(!@stations.include?(vehicle.station_id))
        #@stations.insert(0,vehicle.station_id)
      #end
    end
      @mhnes.insert(0,"all")
  end

  def about
    #https://stackoverflow.com/questions/12719354/rails-3-return-query-results-to-bottom-of-form-page?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    #lista me oxhmata pou exei o xrhsths


  end

  def statistics 
    string=params[:q]
    array=string.split(',')
    xronos=array[0]
    oxhma=array[1]
    station=array[2]
    fuel_type=array[3]
    sugkrish=array[4]
    puts "edwwwww #{sugkrish}"
    #prepei na pros8esw anazhtsh me perioxh
    if(station.include?("none"))
      #otan einai none mporei na upologisei aneksarthta apo to prathrio gia sugkekrimeno xrhsth 
      if(!oxhma.include?("none"))
        #APOTELESMATA GIA XRONO SUGKEKRIMENOU OXHMATOS TOU XRHSTH
        @katanalwsh_mhna=0.0
        @katanalwsh_xronou=0.0
        litra=0.0
        km=0.0
        @vehicle=Vehicle.where(user_id: current_user.id).where(name:oxhma).order(:fuel_date)
        @lt_per_km_monthly=Array.new
        for i in 0..11
          @lt_per_km_monthly[i]=0.0
        end
        if(xronos.include?("all"))
          #upologizei ta xiliometra oloklhro to xrono
          last_km=@vehicle.last.kilometers.to_f
          first_km=@vehicle.first.kilometers.to_f
          km=last_km-first_km
          xronos=xronos.to_i
          counter=0
          @vehicle.each do|vehicle|
            counter+=1 
            if(counter<@vehicle.count)
              litra+=vehicle.liters
            end
          end
          @katanalwsh_xronou=100*litra/km
          for i in 0..11
            @lt_per_km_monthly[i]=calculating(i+1)
          end
          puts "KATANALWSH ANA MHNA"
          puts @lt_per_km_monthly
          puts "KATANALWSH OLOU TOU XRONOU"
          puts @katanalwsh_xronou
          puts "#{km} + #{litra}"
        else
          #Ypologizei xiliometra kai litra gia sugkekrimeno mhna
          @katanalwsh_mhna=calculating(xronos.to_i)
          print "KATANALWSH #{@katanalwsh_mhna}"
        end
      else
          puts "LA8OS ANAZHTHSH"
      end
    else
      #alliws upologizei me bash to prathrio
      if(xronos.include?("all"))&&(oxhma.include?("none"))
        #pollapla oxhmata tou prathriou pou exei balei o xrhsths kausima
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).order(:fuel_date)
        oxhmata_list=Array.new
        @vehicle.each do|vehicle| 
          if(!oxhmata_list.include?(vehicle.name))
            oxhmata_list.insert(0,vehicle.name)
          end
        end
        litra=Array.new(oxhmata_list)
        km=Array.new(oxhmata_list)
        last_km=Array.new(oxhmata_list)
        litra_per_km=Array.new(oxhmata_list)
        for i in 0..oxhmata_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(name: oxhmata_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(name: oxhmata_list[i]).first.kilometers   
        end
        @vehicle.each do|vehicle|
          for i in 0..oxhmata_list.size-1
            if(oxhmata_list[i].include?(vehicle.name))
              if(last_km[i]!=vehicle.kilometers)
                litra[i]=litra[i]+vehicle.liters
              end
            end
          end
        end
        for i in 0..oxhmata_list.size-1
          litra_per_km[i]=100*litra[i]/km[i]
        end
        puts oxhmata_list
        puts km
        puts litra
        puts litra_per_km
      elsif((xronos.include?("all"))&&(!oxhma.include?("none"))&&(sugkrish))
        #PREPEI NA upologizw kai gia ton sugkekrimeno xrhsth sto sugkekrimeno prathrio
        station_id=Station.find_by_name(station).id
        #alliws upologizei me bash to prathrio gia sugkekrimeno oxhma kai tupo kausimou gia diaforetikous xrhstes
        @vehicle=Vehicle.where(station_id: station_id).where(name: oxhma).where(fuel_type:fuel_type).order(:fuel_date)
        user_list=Array.new
        @vehicle.each do|vehicle| 
          if(!user_list.include?(vehicle.user_id))
            user_list.insert(0,vehicle.user_id)
          end
        end
        litra=Array.new(user_list)
        km=Array.new(user_list)
        last_km=Array.new(user_list)
        litra_per_km=Array.new(user_list)
        for i in 0..user_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(user_id: user_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(user_id: user_list[i]).first.kilometers   
        end
        @vehicle.each do|vehicle|
          for i in 0..user_list.size-1
            #if(user_list[i].include?(vehicle.user_id))
            if(user_list[i]==vehicle.user_id)
              if(last_km[i]!=vehicle.kilometers)
                litra[i]=litra[i]+vehicle.liters
              end
            end
          end
        end
        for i in 0..user_list.size-1
          litra_per_km[i]=100*litra[i]/km[i]
        end
        puts user_list
        puts km
        puts litra
        puts litra_per_km
      else
        puts "la8os krithria anazhthshs"
      end
    end
    
    
    
    
    #NA PARW TA PARAMS GIA KATHE STATION KSEXWRISTA 
  end

  def contact
  end

  protected

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
      return katanalwsh_mhna
  end

end
