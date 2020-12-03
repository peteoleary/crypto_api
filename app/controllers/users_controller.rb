require 'bcrypt'

class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :login]

  def scope
    User
  end

  def index
    raise 'Not allowed'
  end

  def login
    @current_user = User.find_by(email: allow_params['email'])
    if @current_user
      if BCrypt::Password.new(@current_user.password) == allow_params['password']
        render json: { token: make_token, user: @current_user.attributes.except('token')}
      else
        render json: {message: 'unauthorized'}, status: 401
      end
    else
      render json: {message: 'not found'}, status: 404
    end

  end

  def refresh
    render json: { token: make_token, user: @current_user.attributes.except('token')}
  end

  protected

  def make_token
    token = BCrypt::Password.create(Random.rand)
    @current_user.token = token
    @current_user.token_expiration = DateTime.now + 30.minutes
    @current_user.save!
    token
  end

  # Only allow a trusted parameter "white list" through.
  def allow_params
    params.permit(:id, :email, :password)
  end
end
