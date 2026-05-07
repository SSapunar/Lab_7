class Pet < ApplicationRecord
  belongs_to :owner, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_one_attached :photo
  validate :photo_valid
  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: %w[dog cat rabbit bird reptile other] }
  validates :date_of_birth, presence: true
  validate :date_not_in_future
  validates :weight, presence: true, numericality: { greater_than: 0 }
  scope :by_species, ->(species) { where(species: species) }
  private
  def date_not_in_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be")
    end
  end
  before_save :capitalize_name
  def capitalize_name
    self.name = name.capitalize if name.present?
  end
  def photo_valid
    return unless photo.attached?
    unless photo.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:photo, "must be a JPEG, PNG, or WebP image")
    end
    if photo.byte_size > 5.megabytes
      errors.add(:photo, "must be smaller than 5 MB")
    end
  end
end