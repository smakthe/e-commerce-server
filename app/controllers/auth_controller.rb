class AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [ :register, :login ]

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
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def user_response(user)
    { id: user.id, full_name: user.full_name, email: user.email }
  end
end