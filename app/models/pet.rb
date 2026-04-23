class Pet < ApplicationRecord
  belongs_to :owner
  has_many :appointments
  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: %w[dog cat rabbit bird reptile other] }
  validates :date_of_birth, presence: true
  validate :date_not_in_future
  validates :weight, presence: true, numericality: { greater_than: 0 }
  private
  def date_not_in_future
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be")
    end
  end
  before_save :capitalize_name
  private
  def capitalize_name
    self.name = name.capitalize if name.present?
  end
end