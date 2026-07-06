class LogIngestionService
  Result = Struct.new(:success?, :log, :errors, keyword_init: true)

  def initialize(token:, log_params:)
    @token = token
    @log_params = log_params
  end

  def call
    service = Service.active.find_by(access_token: @token)
    return Result.new(success?: false, errors: [ "unauthorized" ]) unless service

    log = service.logs.new(
      level: @log_params[:level] || "info",
      message: @log_params[:message],
      hostname: @log_params[:hostname],
      error_code: @log_params[:error_code],
      timestamp: @log_params[:timestamp] || Time.current,
      metadata: @log_params[:metadata] || {}
    )

    if log.save
      BroadcastLogJob.perform_later(log.id)
      Result.new(success?: true, log: log, errors: nil)
    else
      Result.new(success?: false, log: nil, errors: log.errors.full_messages)
    end
  end
end
