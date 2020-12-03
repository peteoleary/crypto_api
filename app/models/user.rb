class User < ApplicationRecord
  before_create :encrypt_password

  private
  def encrypt_password
    self.password = token = BCrypt::Password.create(self.password)
  end
end
