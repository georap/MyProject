class PagesController < ApplicationController
	#IP panepisthmiou 195.130.121.45 ----> request.location
	require 'freegeoip'
  def home
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
  	puts @addresses
  end

  def UserProfile
  end

  def about
  	@ip=Freegeoip.get('195.130.121.45')
  	@station_items=Station.all
  	@addresses=@station_items.to_json.html_safe
  end

  def contact
  end
end
