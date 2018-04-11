class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  	def location
	  if params[:location].blank?
	    if Rails.env.test? || Rails.env.development?
	      @location ||= Geocoder.search("195.130.121.45").first
	    else
	      @location ||= request.location
	    end
	  else
	    params[:location].each {|l| l = l.to_i } if params[:location].is_a? Array
	    @location ||= Geocoder.search(params[:location]).first
	    @location
	  end
	end
end
