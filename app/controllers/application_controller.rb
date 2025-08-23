class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :ensure_demo_user
  helper_method :current_user
  private
  def ensure_demo_user
    # single demo user for now
    @current_user ||= User.first_or_create!(Username: "DemoUser")
  end

  def current_user
    @current_user
  end
end
