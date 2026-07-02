class ServicesController < ApplicationController
  def index
    @services = Service.all
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to services_path, notice: "Service created. Token: #{@service.access_token}"
    else
      @services = Service.all
      render :index, status: :unprocessable_entity
    end
  end

  def regenerate_token
    @service = Service.find(params[:id])
    @service.regenerate_access_token
    redirect_to services_path, notice: "Token regenerated for #{@service.name}"
  end

  private

  def service_params
    params.require(:service).permit(:name, :description)
  end
end
