class ExplorerController < ApplicationController
  def index
    @logs = LogQuery.new(Log.recent, params).call
    @total_events = Log.count
    @error_count = Log.where(level: %w[error critical]).count
    @error_rate = @total_events > 0 ? (@error_count.to_f / @total_events * 100).round(2) : 0
    @service_count = Service.count

    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 20).to_i
    @total = @logs.count
    @total_pages = (@total.to_f / @per_page).ceil
    @logs = @logs.offset((@page - 1) * @per_page).limit(@per_page)
  end
end
