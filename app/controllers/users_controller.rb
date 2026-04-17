class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index, :show ]

  def index
    users = User.all
    render json: users.map { |u| user_response(u) }
  end

  def show
    user = User.find(params[:id])
    render json: user_response(user)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def me
    render json: user_response(current_user)
  end

  def stats
    render json: current_user.dashboard_stats
  end

  def update
    if current_user.update(user_params)
      render json: user_response(current_user)
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    render json: { message: "Account deleted successfully" }, status: :ok
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def user_response(user)
    {
      id:         user.id,
      first_name: user.first_name,
      last_name:  user.last_name,
      full_name:  user.full_name,
      email:      user.email,
      created_at: user.created_at
    }
  end
end