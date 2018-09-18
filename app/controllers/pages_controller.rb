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
    puts @ip
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
    temp_collection=@vehicle.order(fuel_date: :asc)
    @vehicle=@vehicle.order(fuel_date: :desc)
    @litra_pinakas=Array.new
    @date_pinakas=Array.new
    @timh_pinakas=Array.new
    @vehicle_list=Array.new
    @station_list=Array.new
    @categories_list=Array.new
    @name_list=Array.new
    temp_collection.each do|vehicle|
      if(vehicle.price==nil)
        @timh_pinakas.insert(-1,0)
      else
        @timh_pinakas.insert(-1,vehicle.price)
      end
      @date_pinakas.insert(-1,vehicle.fuel_date).to_s
      @litra_pinakas.insert(-1,vehicle.liters)
      @vehicle_list.insert(-1,vehicle.name)
      @station_list.insert(-1,vehicle.station_id)
    end
    for i in 0..@date_pinakas.size-1
      @date_pinakas[i]=@date_pinakas[i].strftime("%m %d %Y")
      station_id=Station.find_by_id(@station_list[i]).name
      @station_list[i]=station_id
      if(!@categories_list.include?(@station_list[i]))
        @categories_list.insert(-1,@station_list[i])
      end
      if(!@name_list.include?(@vehicle_list[i]))
        @name_list.insert(-1,@vehicle_list[i])
      end
    end

    puts @date_pinakas,@litra_pinakas,@timh_pinakas,@vehicle_list,@station_list
    puts "EDWWWWWWWWWWW"
    puts @categories_list

    @date_pinakas=@date_pinakas.to_json.html_safe
    @litra_pinakas=@litra_pinakas.to_json.html_safe
    @timh_pinakas=@timh_pinakas.to_json.html_safe
    @vehicle_list=@vehicle_list.to_json.html_safe
    @station_list=@station_list.to_json.html_safe
    @categories_list=@categories_list.to_json.html_safe
    @name_list=@name_list.to_json.html_safe
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
        if(@vehicle.size>1)
            @katanalwsh_pinakas=Array.new
            @date_pinakas=Array.new
            temp_collection=@vehicle
            @katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
            puts @katanalwsh_pinakas
            puts "hmeromhnia.."
            puts @date_pinakas
            @date_pinakas=@date_pinakas.to_json.html_safe
            @vehicle_name=oxhma.to_json.html_safe
            #@katanalwsh_mhna=calculating(xronos.to_i)
            #upologizei th katanalwsh gia oloklhro to xrono
            last_km=@vehicle.last.kilometers.to_f
            first_km=@vehicle.first.kilometers.to_f
            km=last_km-first_km
            counter=0
            @vehicle.each do|vehicle|
              counter+=1 
              if(counter<@vehicle.count)
                litra+=vehicle.liters
              end
            end
            @katanalwsh_xronou=100*litra/km
            @katanalwsh_xronou=@katanalwsh_xronou.round(3)
        end
=begin        
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
=end
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
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).where(user_id: current_user).order(:fuel_date)
        @oxhmata_list=Array.new
        @vehicle.each do|vehicle| 
          if(!@oxhmata_list.include?(vehicle.name))
            @oxhmata_list.insert(0,vehicle.name)
          end
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
        @katanalwsh_pinakas=Array.new
        @date_pinakas=Array.new
        @statistika=Array.new()
        litra=Array.new(@user_list)
        km=Array.new(@user_list)
        last_km=Array.new(@user_list)
        @lt_per_km_monthly=Array.new(@user_list)
        for i in 0..@user_list.size-1
          litra[i]=0
          last_km[i]=@vehicle.where(user_id: @user_list[i]).last.kilometers
          km[i]=last_km[i]-@vehicle.where(user_id: @user_list[i]).first.kilometers
          temp_collection=@vehicle.where(user_id: @user_list[i])
          @katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
          @statistika.push([@katanalwsh_pinakas,@date_pinakas])   
        end
        puts @statistika
        @titlos=@titlos.to_json.html_safe
        @statistika=@statistika.to_json.html_safe
        @name_list=@user_list.to_json.html_safe
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
        if(@vehicle.size>1)
          @katanalwsh_pinakas=Array.new
          @date_pinakas=Array.new
          temp_collection=@vehicle
          @katanalwsh_pinakas,@date_pinakas=monthly_calc(xronos,temp_collection)
          puts @date_pinakas
          @date_pinakas=@date_pinakas.to_json.html_safe
          @katanalwsh_mhna=calculating(xronos.to_i) 
          @vehicle_name=oxhma.to_json.html_safe 
          puts @katanalwsh_mhna
          
          puts @katanalwsh_pinakas

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
    @my_station=params[:my_station]
    @fuel_type=params[:fuel_type]
    puts "EDWWWWWWWWWWW #{@fuel_type}"
    @array_date= Array.new
    @oxhmata=Array.new
    @vehicle_list=Array.new
    @user_id=Array.new
    @graph_date=Array.new
    @katanalwsh_pinakas=Array.new
   # @type=
    if(!params[:fuel_type].nil?)
      
      puts "EDWWWWWWWWWWW #{@my_station}"
      @vehicle=Vehicle.where(station_id: @my_station).where(fuel_type: @fuel_type).order(:fuel_date)
      
      @vehicle.each do|vehicle|
        if(!@oxhmata.include?(vehicle.name))
          @oxhmata.insert(-1,vehicle.name)
        end
        #oldDate=vehicle.fuel_date.to_s
        #date=Date.parse(oldDate).strftime(%Y,%m,%d)
        #date.gsub(/-/,',')
        #puts date
        @vehicle_list.insert(-1,vehicle.name)
        @array_date.insert(-1,vehicle.fuel_date)
        @user_id.insert(-1,vehicle.user_id)
        #puts @oxhmata
      end
      for i in 0..@vehicle_list.size-1
        puts "#{@vehicle_list[i]} #{@array_date[i]} #{@user_id[i]}"
      end
      puts "diafora"
      mhnes=Array[31,28,31,30,31,30,31,31,30,31,30,31]
      counter=0
      first_date=-1
      second_date=-1
      
      i=0
      pivot=0
      while(i<@vehicle.size)

        first_date,second_date,counter=find_period(i,first_date,second_date,counter)
        if(first_date !=-1 && second_date!=-1)
          if(counter>0)

            @graph_date.insert(-1,@array_date[i],@array_date[i+counter])
            @katanalwsh_pinakas.insert(-1,calc_period(@array_date[i],@array_date[i+counter]))
            if(i==0)
              i=second_date

            else
              i+=counter

            end
          elsif(counter==0)
            
            if(first_date==second_date)
              @graph_date.insert(-1,@array_date[i],@array_date[i+1])
              @katanalwsh_pinakas.insert(-1,calc_period(@array_date[i],@array_date[i+1]))
            else
              @graph_date.insert(-1,@array_date[i],@array_date[i+1])
              @katanalwsh_pinakas.insert(-1,calc_period(@array_date[i],@array_date[i+1]))
            end

          end
        end
        puts "epistrefw tis 8eseis"
        puts first_date,second_date
        puts "epistrefw ton counter"
        puts counter
        puts "-------------"
        counter=0
        first_date=-1
        second_date=-1
        i+=1
      end
      puts @graph_date
      puts @katanalwsh
      @graph_date=@graph_date.to_json.html_safe
      @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
      @vehicle_list=@vehicle_list.to_json.html_safe
      @oxhmata=@oxhmata.to_json.html_safe
      respond_to do |format|
        format.js
      end
      #puts array[0].fuel_date
    end
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
        katanalwsh_mhna[i]=(liters/kiliometers).round(3)
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
    katanalwsh=100*(sum_liters/sum_km).round(2)
    return katanalwsh
  end

end