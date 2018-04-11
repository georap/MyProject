class StationsController < ApplicationController
	def index
		@station_items=Station.all
	end

end
