class Review < ApplicationRecord
  belongs_to :user
  belongs_to :station
  validates :content, presence:true, length: {minimum:3, maximum: 1000}

  after_create_commit { ReviewBroadcastJob.perform_later(self)}
end
