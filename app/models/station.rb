class Station < ApplicationRecord
 HEAD
	require 'rubygems'
	require 'json'
	has_many :reviews, dependent: :destroy
	has_many :vehicles, dependent: :destroy
	before_save :uppercase_fields

 master
	if(:address != nil)
		geocoded_by :address
		after_validation :geocode, if: :address_changed?
	end
	if (:latitude != nil)&&(:longitude != nil)
		
		reverse_geocoded_by :latitude, :longitude,
	  	:address => :address
		after_validation :reverse_geocode, if: :latitude_changed? || :longitude_changed?
 HEAD
		
 master
	end

protected
def uppercase_fields
  self.company.upcase!
end

end
