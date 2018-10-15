class Station < ApplicationRecord
	require 'rubygems'
	require 'json'
	has_many :reviews, dependent: :destroy
	has_many :vehicles, dependent: :destroy
	before_save :uppercase_fields

	if(:address != nil)
		
		geocoded_by :address
		after_validation :geocode, if: :address_changed?
	end
	if (:latitude != nil)&&(:longitude != nil)
		
		# @data={"address_components"=>[{"long_name"=>"50", "short_name"=>"50", "types"=>["street_number"]}, {"long_name"=>"Παναγιώτη Ασημακόπουλου", "short_name"=>"Παναγιώτη Ασημακόπουλου", "types"=>["route"]}, {"long_name"=>"Κάτω Νεοχωρόπουλο", "short_name"=>"Κάτω Νεοχωρόπουλο", "types"=>["locality", "political"]}, {"long_name"=>"Ιωάννινα", "short_name"=>"Ιωάννινα", "types"=>["administrative_area_level_3", "political"]}, {"long_name"=>"Ελλάδα", "short_name"=>"GR", "types"=>["country", "political"]}, {"long_name"=>"455 00", "short_name"=>"455 00", "types"=>["postal_code"]}], "formatted_address"=>"Παναγιώτη Ασημακόπουλου 50, Κάτω Νεοχωρόπουλο 455 00, Ελλάδα", "geometry"=>{"location"=>{"lat"=>39.6385285, "lng"=>20.8399281}, "location_type"=>"ROOFTOP", "viewport"=>{"northeast"=>{"lat"=>39.6398774802915, "lng"=>20.8412770802915}, "southwest"=>{"lat"=>39.6371795197085, "lng"=>20.83857911970849}}}, "place_id"=>"ChIJE2hnVg7pWxMRsjdpXdSj3zQ", "plus_code"=>{"compound_code"=>"JRQQ+CX Κάτω Νεοχωρόπουλο, Ιωάννινα, Ελλάδα", "global_code"=>"8GF2JRQQ+CX"}, "types"=>["street_address"]}, @cache_hit=true>
		reverse_geocoded_by :latitude, :longitude,
	  	:address => :address
		after_validation :reverse_geocode, if: :latitude_changed? || :longitude_changed?
		
	end

protected
def uppercase_fields
  self.company.upcase!
end

end
