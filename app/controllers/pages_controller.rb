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
    puts data["city"]
    if(data["city"]=="Ioannina")
      @station_items=Station.where("address like ?", "%Ιωαννίνων%").or(Station.where("address like ?", "%Ιωάννινα%"))
    else
      @station_items=Station.all
    end
    lat='latitude'
    long='longitude'
    @ip=[data[lat],data[long]]
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
        
        consumption_array=find_consumption_2(km_array,lt_array,"station")
        puts consumption_array
        
        @katanalwsh_pinakas=fill_katanalwsh_array(consumption_array)
        puts "--------------------------------"
        puts @katanalwsh_pinakas
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
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).where(user_id: current_user).order(:fuel_date)
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
        @second_graph_array=fill_katanalwsh_array(consumption_array)
        #puts consumption_array
        #puts '--------------------'
        #puts @katanalwsh_pinakas
        puts @second_graph_array
        @second_graph_array=@second_graph_array.to_json.html_safe
        @array_date=@array_date.uniq
        @array_date=@array_date.to_json.html_safe
        @date_pinakas=@date_pinakas.to_json.html_safe
        #puts @date_pinakas
      elsif((xronos.include?("all"))&&(!oxhma.include?("none"))&&(sugkrish))
        #alliws upologizei me bash to prathrio gia sugkekrimeno oxhma kai TYPO KAYSIMOY gia diaforetikous xrhstes
        @case=3
        station_id=Station.find_by_name(station).id
        @vehicle=Vehicle.where(station_id: station_id).where(name: oxhma).where(fuel_type:fuel_type).order(:fuel_date)
        @user_list=Array.new
        @array_date=Array.new
        km_array=Array.new
        lt_array=Array.new
        @vehicle_list=Array.new
        @user_id=Array.new
        @vehicle.each do|vehicle| 
          if(!@user_list.include?(vehicle.user_id))
            @user_list.insert(0,vehicle.user_id)
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
        consumption_array=find_consumption_2(km_array,lt_array,0)
        @second_graph_array=fill_katanalwsh_array(consumption_array)
        @second_graph_array=@second_graph_array.to_json.html_safe
        @array_date=@array_date.uniq
        @array_date=@array_date.to_json.html_safe
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
    km_array=Array.new
    lt_array=Array.new
    @graph_date=Array.new
    @message=-1
   # @type=
    if(!params[:fuel_type].nil?)
      
      puts "EDWWWWWWWWWWW #{@my_station}"
      @vehicle=Vehicle.where(station_id: @my_station).where(fuel_type: @fuel_type).order(:fuel_date)
      puts @vehicle.size
      if(@vehicle.size!=0)

        @message=0
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
          km_array.insert(-1,vehicle.kilometers)
          lt_array.insert(-1,vehicle.liters)
          #puts @oxhmata
        end

        @katanalwsh_pinakas=Array.new#(@array_date.size,0)
        for i in 0..@vehicle_list.size-1
            puts "#{@vehicle_list[i]} #{@array_date[i]} #{@user_id[i]}"
        end
        puts "diafora"
        first_date=-1
        second_date=-1
        counter=0
        #first_date,second_date,counter=find_period(0,first_date,second_date,counter)
        #puts counter,first_date,second_date
        #first_date,second_date,counter=find_period(0,first_date,second_date,counter)
        puts counter,first_date,second_date
        consumption_array=Array.new
        #ypologise thn katanalwsh ana 2 gia ka8e eggrafh
        #i=0
        #while (i<array_date.size)
        consumption_array=find_consumption_2(km_array,lt_array,0)
        puts consumption_array
        
        @katanalwsh_pinakas=fill_katanalwsh_array(consumption_array)
        #afairesh diploeggrafwn tou pinaka
        @graph_date=@array_date.uniq
        #puts "katanalwsh_pinakas"
        puts @katanalwsh_pinakas
        #puts @graph_date
        #puts @katanalwsh
        @graph_date=@graph_date.to_json.html_safe
        @katanalwsh_pinakas=@katanalwsh_pinakas.to_json.html_safe
        @vehicle_list=@vehicle_list.to_json.html_safe
        @oxhmata=@oxhmata.to_json.html_safe
        respond_to do |format|
          format.js
        end
        #puts array[0].fuel_date
      else

      @message="Δεν υπάρχουν εγγραφές στο σύστημα για αυτή την επιλογή"
      puts @message

      @message=@message.to_json.html_safe
      respond_to do |format|
          format.js
        end
      end  
    end 
  end


  protected

  

  def fill_katanalwsh_array(consumption_array)
    #dhmiourgia range interval tree

    temp_collection=Array.new
    range_tree =  RangeTree::Tree.new
    i=0
    while (i<consumption_array.size-6)
      first_date=Date.strptime(consumption_array[i].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
      second_date=Date.strptime(consumption_array[i+1].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
      range_tree[first_date.to_i,second_date.to_i]=consumption_array[i+5]
      i=i+6
    end
    staff_holidays = RangeTree::Tree.new
    
    #parser=Date.strptime(consumption_array[0],"%Y-%m-%d").strftime("%Y_%m_%d")
    parser=Date.strptime(consumption_array[0].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
    objectee=2000_01_01
    #puts consumption_array[0].is_a?(Date)


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
              puts "#{@array_date[i]}  #{@array_date[i+1]}"
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
                  
                    puts "KALHSPERA #{@array_date[i]} #{@array_date[i+1]}"
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
            puts "#{@array_date[i]} #{@array_date[i+1]}"
            puts "to range query einai #{range_query}"
            second_flag=false
            previous_consumption=0
            range_query=range_query.uniq
            for k in 0..range_query.size-1
              temp_pos=consumption_array.find_index(range_query[k])
              date_temp_last=consumption_array[temp_pos-4]
              date_temp_first=consumption_array[temp_pos-5]
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
    return temp_collection
  end

  def calc_day(position_first,position_second)
    mhnes=Array[0,31,28,31,30,31,30,31,31,30,31,30,31]
    first_month=@array_date[position_first].strftime("%m").to_i
    second_month=@array_date[position_second].strftime("%m").to_i
    first_day=@array_date[position_first].strftime("%d").to_i
    second_day=@array_date[position_second].strftime("%d").to_i
    days=0
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
            days=calc_day(i,j)
            temp_array.insert(-1,days)
            puts "hohohoohhohoohhoho #{km_array[j]} - #{km_array[start_date]}"
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