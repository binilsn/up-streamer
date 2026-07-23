class ServerCheckIngestionService
  Result = Struct.new(:success?, :server_check, :errors, keyword_init: true)

  def initialize(token:, params:)
    @token = token
    @params = params
  end

  def call
    service = Service.active.find_by(access_token: @token)
    return Result.new(success?: false, errors: [ "unauthorized" ]) unless service

    check = service.server_checks.new(
      status: @params.key?(:status) ? @params[:status] : "up",
      response_time_ms: @params[:response_time_ms],
      ssl_valid: @params[:ssl_valid],
      ssl_expires_at: @params[:ssl_expires_at],
      ssl_issuer: @params[:ssl_issuer],
      checked_at: @params.key?(:checked_at) ? @params[:checked_at] : Time.current,
      metadata: @params[:metadata] || {}
    )

    if check.save
      Result.new(success?: true, server_check: check, errors: nil)
    else
      Result.new(success?: false, server_check: nil, errors: check.errors.full_messages)
    end
  end
end
