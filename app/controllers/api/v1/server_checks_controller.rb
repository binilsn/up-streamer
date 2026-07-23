class Api::V1::ServerChecksController < ApplicationController
  wrap_parameters false
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :authenticate_service, only: :create

  # POST /api/v1/server_checks
  def create
    result = ServerCheckIngestionService.new(token: @service.access_token, params: server_check_params).call

    if result.success?
      render json: { id: result.server_check.id, message: "Server check ingested" }, status: :created
    else
      status = result.errors.include?("unauthorized") ? :unauthorized : :unprocessable_content
      render json: { errors: result.errors }, status: status
    end
  end

  # GET /api/v1/server_checks
  def index
    checks = ServerCheck.latest_per_service.recent
    render json: {
      data: checks.map { |c| serialize_check(c) }
    }
  end

  private

  def authenticate_service
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")&.strip
    @service = Service.active.find_by(access_token: token)
    render json: { errors: [ "unauthorized" ] }, status: :unauthorized unless @service
  end

  def server_check_params
    params.permit(:status, :response_time_ms, :ssl_valid, :ssl_expires_at, :ssl_issuer, :checked_at, metadata: {})
  end

  def serialize_check(check)
    {
      id: check.id,
      service: check.service.name,
      status: check.status,
      response_time_ms: check.response_time_ms,
      ssl_valid: check.ssl_valid,
      ssl_expires_at: check.ssl_expires_at,
      ssl_issuer: check.ssl_issuer,
      checked_at: check.checked_at,
      metadata: check.metadata,
      created_at: check.created_at
    }
  end
end
