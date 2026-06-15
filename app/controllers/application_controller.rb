# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Pundit's principal is a UserContext (current_user == true_user here; the real
  # Enni threads an impersonated user through the same shape).
  def pundit_user
    UserContext.new(current_user: current_user, true_user: current_user)
  end

  def user_not_authorized
    flash[:alert] = "You are not allowed to do that."
    redirect_back_or_to(root_path)
  end
end
