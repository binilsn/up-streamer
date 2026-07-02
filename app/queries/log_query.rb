class LogQuery
  FILTERS = %i[ level service hostname error_code q from to ].freeze

  def initialize(relation = Log.all, params = {})
    @relation = relation
    @params = params
  end

  def call
    filter_by_level
    filter_by_levels
    filter_by_service
    filter_by_hostname
    filter_by_error_code
    search_message
    filter_by_from
    filter_by_to
    @relation
  end

  private

  def filter_by_level
    return unless @params[:level].present?
    @relation = @relation.by_level(@params[:level])
  end

  def filter_by_levels
    return unless @params[:levels].present?
    @relation = @relation.by_levels(@params[:levels].split(","))
  end

  def filter_by_service
    return unless @params[:service].present?
    @relation = @relation.by_service(@params[:service])
  end

  def filter_by_hostname
    return unless @params[:hostname].present?
    @relation = @relation.by_hostname(@params[:hostname])
  end

  def filter_by_error_code
    return unless @params[:error_code].present?
    @relation = @relation.by_error_code(@params[:error_code])
  end

  def search_message
    return unless @params[:q].present?
    @relation = @relation.search_message(@params[:q])
  end

  def filter_by_from
    return unless @params[:from].present?
    @relation = @relation.since(@params[:from])
  end

  def filter_by_to
    return unless @params[:to].present?
    @relation = @relation.until(@params[:to])
  end
end
