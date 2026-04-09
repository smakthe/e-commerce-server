# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index, :show ]

  # GET /users
  def index
    users = User.all
    render json: users.map { |u| user_response(u) }
  end

  # GET /users/:id
  def show
    user = User.find(params[:id])
    render json: user_response(user)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  # GET /users/me
  def me
    render json: user_response(current_user)
  end

  # PATCH /users/me
  def update
    if current_user.update(user_params)
      render json: user_response(current_user)
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/me
  def destroy
    current_user.destroy
    render json: { message: "Account deleted successfully" }, status: :ok
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation)
  end

  def user_response(user)
    {
      id: user.id,
      username: user.username,
      email: user.email,
      created_at: user.created_at
    }
  end
end
