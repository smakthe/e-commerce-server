# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = extract_token
    if token.nil?
      render json: { error: "Missing authorization token" }, status: :unauthorized
      return
    end

    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  def extract_token
    header = request.headers["Authorization"]
    header&.split(" ")&.last
  end

  def current_user
    @current_user
  end
end
