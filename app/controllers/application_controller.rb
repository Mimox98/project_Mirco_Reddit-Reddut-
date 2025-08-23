class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :ensure_demo_user
  helper_method :current_user

  private

  def ensure_demo_user
  @current_user = User.find_by(id: cookies.signed[:demo_user_id]) if cookies.signed[:demo_user_id]
  return if @current_user

  @current_user = User.create!(Username: "DemoUser#{SecureRandom.random_number(10_000).to_s.rjust(4, '0')}")
  cookies.signed.permanent[:demo_user_id] = @current_user.id
  end

  def current_user
    @current_user
  end
end
