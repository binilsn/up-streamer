class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :all_services, :selected_service_name

  private

  def all_services
    @all_services ||= Service.active.order(:name).pluck(:name)
  end

  def selected_service_name
    return nil if params[:service].blank? || params[:service] == "all"
    params[:service]
  end
end
