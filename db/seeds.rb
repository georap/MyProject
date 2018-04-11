# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'rubygems'
require 'rubyXL'

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