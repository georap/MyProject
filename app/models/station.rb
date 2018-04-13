class Station < ApplicationRecord
	if(:address != nil)
		geocoded_by :address
		after_validation :geocode, if: :address_changed?
	end
	if (:latitude != nil)&&(:longitude != nil)
		reverse_geocoded_by :latitude, :longitude,
	  	:address => :address
		after_validation :reverse_geocode, if: :latitude_changed? || :longitude_changed?
	end
end
