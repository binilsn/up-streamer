class LogQuery
  FILTERS = %i[ level service hostname error_code q from to ].freeze

  def initialize(relation = Log.all, params = {})
    @relation = relation
    @params = params
    @structured_applied = false
    @free_text = nil
  end

  def call
    filter_by_level
    filter_by_levels
    filter_by_service
    filter_by_hostname
    filter_by_error_code
    apply_structured_search
    search_message
    filter_by_from
    filter_by_to
    @relation
  end

  private

  def apply_structured_search
    raw_q = @params[:q].to_s.strip
    return if raw_q.blank?

    result = LogSearchParser.new(raw_q).call
    return unless result.any?

    @structured_applied = true
    result.filters.each { |filter| apply_filter(filter) }

    # Store remaining plain text separately instead of mutating params
    @free_text = result.plain_text.presence
  end

  def search_message
    text = @structured_applied ? @free_text : @params[:q]
    return unless text.present?
    @relation = @relation.search_message(text)
  end

  def apply_filter(filter)
    case filter.field
    when "service"
      @relation = @relation.by_service(filter.value)
    when "level"
      @relation = @relation.by_level(filter.value)
    when "host"
      @relation = @relation.by_hostname(filter.value)
    when "error_code"
      @relation = @relation.by_error_code(filter.value)
    when "message"
      @relation = @relation.search_message(filter.value)
    when "tag"
      @relation = @relation.by_tag(filter.value)
    when "status", "env", "path", "trace_id", "request_id"
      @relation = @relation.by_metadata_eq(filter.field, filter.value)
    when "duration"
      apply_duration_filter(filter)
    end
  end

  def apply_duration_filter(filter)
    case filter.operator
    when ">"
      @relation = @relation.by_metadata_gt("duration", filter.value)
    when ">="
      @relation = @relation.by_metadata_gte("duration", filter.value)
    when "<"
      @relation = @relation.by_metadata_lt("duration", filter.value)
    when "<="
      @relation = @relation.by_metadata_lte("duration", filter.value)
    when "="
      @relation = @relation.by_metadata_eq("duration", filter.value)
    end
  end

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

  def filter_by_from
    return unless @params[:from].present?
    @relation = @relation.since(@params[:from])
  end

  def filter_by_to
    return unless @params[:to].present?
    @relation = @relation.until(@params[:to])
  end
end
