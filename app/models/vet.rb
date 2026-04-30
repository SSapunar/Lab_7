class Vet < ApplicationRecord
  has_many :appointments, dependent: :destroy
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :specialization, presence: true

  before_validation :normalize_email
  scope :by_specialization, ->(specialization) { where(specialization: specialization) }
  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end