# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'rubygems'
require 'rubyXL'
require 'date'
=begin
workbook = RubyXL::Parser.parse '/home/ga/Επιφάνεια εργασίας/diplomatiki/ΜΗΤΡΩΟ ΠΡΑΤΗΡΙΩΝ ΥΓΡΩΝ ΚΑΥΣΙΜΩΝ.xlsx'
worksheets = workbook.worksheets
addresses= Array.new
worksheets.each do |worksheet|
	num_rows = 0
	#list of words that doesnt work with geocoding
	banList=["+","χλμ","θέση","Ε.Ο.","Επ.Ο.","ΕΠ.Ο.","Π.Ε.Ο.","(","αγρ.","Τέρμα","τέρμα"]
  	worksheet.each do |row|
	
	  	if row
		    row_cells = row.cells.map{ |cell| cell.value }
		    
		    # if its integer and not nil in Dimos
		    if (row_cells[1].is_a? Integer) && (row_cells[2]!=nil)&& (row_cells[3]!=nil)&&(row_cells[4]!=nil)&&(row_cells[5]!=nil)
		    	#puts "To AFM einai: #{row_cells[1]} , To onoma ths etaireias einai: #{row_cells[2]},H dieu8unsh einai #{row_cells[3]} dhmou: #{row_cells[4]}"
				flag=true
				banList.each do |i|
					if(row_cells[3].include? i)
						flag=false
					end
				end
				if(flag)
					if(row_cells[3].include? ",")
				    		s=row_cells[3]
					else
						s=row_cells[3]+','+row_cells[5]
					end
					#remove duplicates
					if(!addresses.include? s)
						addresses.insert(0,s)
						#create the elements of database take name and address
						Station.create!(name:"#{row_cells[2]}",address:"#{s}")
					end
					
				    	num_rows += 1
				end
		    end
		end
  	end
end
=end
name=["Fiat Panda","Mercedes-Benz A-Class","Peugeot 308","Nissan Micra","Volkswagen Polo","Citroen Saxo","Opel Corsa","Mitsubishi Asx","Daewoo Matiz","Skoda Fabia","Audi A3","Audi A4"]
kiliometers=[170500,120150,168025,135658,27580,56325,149058,78965,45895,98654,56478,36789]
fuel_date=["2018-01-04","2018-01-02","2018-01-06","2018-01-07","2018-01-01","2018-01-05","2018-01-09","2018-01-03","2018-01-14","2018-01-05","2018-01-13","2018-01-07"]
fuel_type=["Βενζίνη","Πετρέλαιο","Βενζίνη","Πετρέλαιο","Βενζίνη","Βενζίνη","Βενζίνη","Πετρέλαιο","Βενζίνη","Πετρέλαιο","Βενζίνη","Βενζίνη"]
user_id=[5,6,6,5,7,7,7,6,8,8,4,5]
station_id=[1041,1061,1061,1041,450,450,442,1061,2044,2046,2044,2044]
area=["Ιωάννινα","Ιωάννινα","Ιωάννινα","Ιωάννινα","Άρτα","Άρτα","Άρτα","Ιωάννινα","Πρέβεζα","Πρέβεζα","Πρέβεζα","Πρέβεζα"]
weeks=365/7.to_i
random_km=[500,350,200,450]
random_lt=[40,20,10,35]
random_price=[60,30,15,50]
#puts 300.times.map{Random.rand(3)}
#parser=Date.strptime(fuel_date[0].to_s,"%Y-%m-%d").strftime("%Y_%m_%d")
#puts parser.is_a?(String)
for j in 0..fuel_date.size-1
	fuel_date[j]= Date.parse fuel_date[j]
end
mhnes=Array[0,31,28,31,30,31,30,31,31,30,31,30,31]
new_date=["","","","","","","","","","","",""]
new_km=[0,0,0,0,0,0,0,0,0,0,0,0]

for i in 1..weeks
	for j in 0..name.size-1
		#random
		liters=0
		price=0
		random_number=Random.rand(4)
		#puts "RANDOM=#{random_number}"
		#calculation of next day after one week
		flag=true
		string=name[j].split(" ")
		brand=string[0]
		model=string[1]
		if(i==1)
			day=fuel_date[j].strftime("%d").to_i
			month=fuel_date[j].strftime("%m").to_i
			year=fuel_date[j].strftime("%Y").to_i
			#first km and random liters,price
			new_km[j]=kiliometers[j]
			liters=random_lt[random_number]
			price=random_price[random_number]
			flag=false
			#create here the first vehicles
			Vehicle.create!(brand:"#{brand}",model:"#{model}",kilometers:new_km[j],liters:liters,fuel_date:fuel_date[j],fuel_type:"#{fuel_type[j]}",area:"#{area[j]}",user_id:user_id[j],station_id:station_id[j],price:price)
			new_date[j]=fuel_date[j]
		else
			day=new_date[j].strftime("%d").to_i
			month=new_date[j].strftime("%m").to_i
			year=new_date[j].strftime("%Y").to_i
			#calculation of kiliometers
			new_km[j]+=random_km[random_number]+Random.rand(100)
			#random price,liters
			liters=random_lt[random_number]
			price=random_price[random_number]
		end
		#day=fuel_date[0].strftime("%d").to_i
		#month=fuel_date[0].strftime("%m").to_i
		

		#create Vehicle with name,kiliometers,liters,fuel_date,fuel_type,user_id,station_id
		if(flag)
			sum_month=mhnes[month]
			if(day+7>sum_month)
				month+=1
				remaining_days=sum_month-day
				day=7-remaining_days
				if(month>12)
					month=1
					year+=1
				end
			else
				day+=7
			end
			new_date[j]=year.to_s+"-"+month.to_s+"-"+day.to_s
			new_date[j]=Date.parse new_date[j]
			#create the other elements
			Vehicle.create!(brand:"#{brand}",model:"#{model}",kilometers:new_km[j],liters:liters,fuel_date:new_date[j],fuel_type:"#{fuel_type[j]}",area:"#{area[j]}",user_id:user_id[j],station_id:station_id[j],price:price)
			#puts name[j],new_date[j],new_km[j],liters,price,area[j],user_id[j],station_id[j]
		end
	end
end


workbook = RubyXL::Parser.parse '/home/ga/Επιφάνεια εργασίας/diplomatiki/vehicles.xlsx'
worksheets = workbook.worksheets
puts "Found #{worksheets.count} worksheets"
worksheets.each do |worksheet|
  puts "Reading: #{worksheet.sheet_name}"
  num_rows = 0
  	worksheet.each do |row|
	
  		if row
			if (num_rows!=0)
				row_cells = row.cells.map{ |cell| cell.value }
				num_rows += 1
				string=row_cells[0].split(" ")
				brand=string[0]
				model=string[1]
				#create vehicles name kiliometers liters price fuel_date, fuel_type, area station_id, user_id
				#puts row_cells[0],row_cells[1],row_cells[2].to_f,row_cells[3],row_cells[4],row_cells[5],row_cells[6],row_cells[7],row_cells[8]
				Vehicle.create!(brand:"#{brand}",model:"#{model}",kilometers:row_cells[1],liters:row_cells[2].to_f,fuel_date:row_cells[4],fuel_type:"#{row_cells[5]}",area:"#{row_cells[6]}",user_id:row_cells[8],station_id:row_cells[7],price:row_cells[3])
			else
				num_rows += 1
			end
			
		end
	end
	puts "Read #{num_rows} rows"
end