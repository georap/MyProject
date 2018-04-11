class PagesController < ApplicationController
	#IP panepisthmiou 195.130.121.45 ----> request.location
  def home
  	@addresses=Array.new
  	@station_items=Station.all
  	@station_items.each do|station_item|
  		name0=station_item.name
  		longitude0=station_item.longitude
  		latitude0=station_item.latitude
  		if(longitude0!=nil)&&(longitude0!=nil)
  			longitude0=longitude0.to_s
  			latitude0=latitude0.to_s
  			temp=name0+'$'+longitude0+'$'+latitude0
  			@addresses.insert(0,temp)
  		end
  	end
  	puts @addresses.to_json
  end

  def UserProfile
  end

  def about
  	@station_items=Station.all
  	@addresses=@station_items.to_json.html_safe
  end

  def contact
  end
end
