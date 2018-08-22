module ApplicationHelper
	def check_guest_user
    	forbidden! if current_user.is_a? GuestUser
  	end
end
