class PagesController < ApplicationController
  include ApplicationHelper
  #access all: [:home,:about,:contact], user: :all, site_admin: :all
  before_action :check_guest_user, only: [:UserProfile,:statistics]

  
	#IP panepisthmiou 195.130.121.45 ----> request.location
  require 'net/http'
	require 'freegeoip'
  require 'json'

  def home
    @user_auth=false
    if (current_user.is_a?(GuestUser))
      @user_auth=false
    else
      @user_auth=true
    end
    text=ipRequest()
    data=JSON.parse(text)
    lat='latitude'
    long='longitude'
    @ip=[data[lat],data[long]]
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
        
        for i in 0..11
          @lt_per_km_monthly[i]=0.0
        end
        #if(xronos.include?("all"))
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
      elsif(!oxhma.include?("none"))&&(!xronos.include?("all"))
          #Ypologizei xiliometra kai litra gia sugkekrimeno mhna
          @case=1
          @vehicle=Vehicle.where(user_id: current_user.id).where(name:oxhma).where(user_id: current_user).where('extract(month from fuel_date) = ?', xronos).order(:fuel_date)
          if(@vehicle.size!=0)
            @katanalwsh_mhna=calculating(xronos.to_i)
            print "KATANALWSH #{@katanalwsh_mhna}"
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
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).order(:fuel_date)
        @oxhmata_list=Array.new
        @vehicle.each do|vehicle| 
          if(!@oxhmata_list.include?(vehicle.name))
            @oxhmata_list.insert(0,vehicle.name)
          end
        end
        litra=Array.new(@oxhmata_list)
        km=Array.new(@oxhmata_list)
        last_km=Array.new(@oxhmata_list)
        @lt_per_km_monthly=Array.new(@oxhmata_list)
        for i in 0..@oxhmata_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(name: @oxhmata_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(name: @oxhmata_list[i]).first.kilometers   
        end
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
        puts station
        puts @oxhmata_list
        puts km
        puts litra
        puts @lt_per_km_monthly
      elsif((xronos.include?("all"))&&(!oxhma.include?("none"))&&(sugkrish))
        #alliws upologizei me bash to prathrio gia sugkekrimeno oxhma kai TYPO KAYSIMOY gia diaforetikous xrhstes
        @case=3
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).where(name: oxhma).where(fuel_type:fuel_type).order(:fuel_date)
        @user_list=Array.new
        @vehicle.each do|vehicle| 
          if(!@user_list.include?(vehicle.user_id))
            @user_list.insert(0,vehicle.user_id)
          end
        end
        litra=Array.new(@user_list)
        km=Array.new(@user_list)
        last_km=Array.new(@user_list)
        @lt_per_km_monthly=Array.new(@user_list)
        for i in 0..@user_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(user_id: @user_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(user_id: @user_list[i]).first.kilometers   
        end
        @vehicle.each do|vehicle|
          for i in 0..@user_list.size-1
            if(@user_list[i]==vehicle.user_id)
              if(last_km[i]!=vehicle.kilometers)
                litra[i]=litra[i]+vehicle.liters
              end
            end
          end
        end
        for i in 0..@user_list.size-1
          @lt_per_km_monthly[i]=100*litra[i]/km[i]
        end
        puts xronos.include?("all")&&!oxhma.include?("none")&&sugkrish
        puts @user_list
        puts km
        puts litra
        puts @lt_per_km_monthly
        if (@lt_per_km_monthly.size==0)
          @error_message='DEN YPARXOYN OI XRHSTES KAI H EGGRAFH TOY OXHMATOS '+ oxhma+' STO PRATHRIO ' +station+' TON MHNA '+ xronos+' ME AYTO TON TYPO KAYSIMOU ' +fuel_type
        end
      elsif ((!xronos.include?("all"))&&(!oxhma.include?("none")))
        # upologizw kai gia ton xrhsth sto sugkekrimeno prathrio to sugkekrimeno mhna to sugkekrimeno oxhma me tupo kausimou
        @case=4
        station_id=Station.find_by_name(station).id   
        @vehicle=Vehicle.where(station_id: station_id).where(name: oxhma).where(fuel_type:fuel_type).where(user_id: current_user).where('extract(month from fuel_date) = ?', xronos).order(:fuel_date)
        puts @vehicle.inspect
        puts @vehicle.size
        if(@vehicle.size!=0)
          @katanalwsh_mhna=calculating(xronos.to_i)  
          puts @katanalwsh_mhna
        else
          @error_message='DEN YPARXEI H EGGRAFH TOY OXHMATOS '+ oxhma+' STO PRATHRIO ' +station+' TON MHNA '+ xronos+' ME AYTO TON TYPO KAYSIMOU ' +fuel_type
          puts "DEN YPARXEI H EGGRAFH TOY OXHMATOS #{oxhma} STO PRATHRIO #{station} TON MHNA #{xronos}ME AYTO TON TYPO KAYSIMOU #{fuel_type}" 
        end
      else
        @error_message='la8os krithria anazhthshs'
        puts "la8os krithria anazhthshs"
        
      end
    end
    
    
    
    
    #NA PARW TA PARAMS GIA KATHE STATION KSEXWRISTA 
  end

  def contact
  end

  protected

  

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
      return katanalwsh_mhna
  end

end
