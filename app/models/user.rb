class User < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name,  presence: true
  validates :email,      presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,   length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def full_name
    "#{first_name} #{last_name}"
  end
end