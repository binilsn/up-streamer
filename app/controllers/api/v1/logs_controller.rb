class Api::V1::LogsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_service, only: :create

  MAX_PER_PAGE = 200
  DEFAULT_PER_PAGE = 50

  # POST /api/v1/logs
  def create
    result = LogIngestionService.new(token: @service.access_token, log_params: log_params).call

    if result.success?
      render json: { id: result.log.id, message: "Log ingested" }, status: :created
    else
      status = result.errors.include?("unauthorized") ? :unauthorized : :unprocessable_entity
      render json: { errors: result.errors }, status: status
    end
  end

  # GET /api/v1/logs
  def index
    logs = Log.recent

    logs = logs.by_level(params[:level]) if params[:level].present?
    logs = logs.by_levels(params[:levels].split(",")) if params[:levels].present?
    logs = logs.by_service(params[:service]) if params[:service].present?
    logs = logs.by_hostname(params[:hostname]) if params[:hostname].present?
    logs = logs.by_error_code(params[:error_code]) if params[:error_code].present?
    logs = logs.search_message(params[:q]) if params[:q].present?
    logs = logs.since(params[:from]) if params[:from].present?
    logs = logs.until(params[:to]) if params[:to].present?

    page = (params[:page] || 1).to_i
    per_page = [ (params[:per_page] || DEFAULT_PER_PAGE).to_i, MAX_PER_PAGE ].min

    total = logs.count
    logs = logs.offset((page - 1) * per_page).limit(per_page)

    render json: {
      data: logs.map { |l| serialize_log(l) },
      meta: {
        page: page,
        per_page: per_page,
        total: total,
        total_pages: (total.to_f / per_page).ceil
      }
    }
  end

  # GET /api/v1/logs/:id
  def show
    log = Log.find(params[:id])
    render json: { data: serialize_log(log) }
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [ "not found" ] }, status: :not_found
  end

  private

  def authenticate_service
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")&.strip
    @service = Service.active.find_by(access_token: token)
    render json: { errors: [ "unauthorized" ] }, status: :unauthorized unless @service
  end

  def log_params
    params.permit(:level, :message, :hostname, :error_code, :timestamp, metadata: {})
  end

  def serialize_log(log)
    {
      id: log.id,
      timestamp: log.timestamp,
      level: log.level,
      service: log.service.name,
      message: log.message,
      hostname: log.hostname,
      error_code: log.error_code,
      metadata: log.metadata
    }
  end
end
