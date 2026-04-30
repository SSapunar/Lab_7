class Owner < ApplicationRecord
  has_many :pets, dependent: :destroy
  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  before_validation :normalize_email
  private
  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end