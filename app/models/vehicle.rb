class Vehicle < ApplicationRecord
  belongs_to :user
  belongs_to :station
	before_save :set_name 

	protected
	def set_name
    	self.name = "#{brand} #{model}"
  	end
end
