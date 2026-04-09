# frozen_string_literal: true

class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [ :register, :login ]

  # POST /auth/register
  def register
    user = User.new(register_params)

    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        message: "Account created successfully",
        user: user_response(user),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /auth/login
  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: {
        message: "Logged in successfully",
        user: user_response(user),
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def register_params
    params.permit(:username, :email, :password, :password_confirmation)
  end

  def user_response(user)
    { id: user.id, username: user.username, email: user.email }
  end
end
