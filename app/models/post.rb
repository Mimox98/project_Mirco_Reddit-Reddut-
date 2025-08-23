class Post < ApplicationRecord
  SUBREDDITS = [
    "r/programming",
    "r/AiReplacesHumans",
    "r/AiWIllTakeMyJob",
    "r/Steuergeld",
    "r/pleaseHireMeASAP",
    "r/WhyShouldUHireMe",
    "r/Ranting"
  ].freeze
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :subreddit, :title, presence: true
  validates :subreddit, inclusion: { in: SUBREDDITS }
  validate :text_or_image

  private
  def text_or_image
    if body.blank? && image_url.blank?
      errors.add(:base, "Provide body (text post) or image_url (image post)")
    end
  end
end
