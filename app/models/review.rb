class Review < ApplicationRecord
  belongs_to :user
  belongs_to :station
  validates :content, presence:true, length: {minimum:5, maximum: 1000}

  after_create_commit { ReviewBroadcastJob.perform_later(self)}
end
