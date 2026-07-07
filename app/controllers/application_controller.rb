class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :all_services, :selected_service_name, :remove_filter_from_query

  private

  def all_services
    @all_services ||= Service.active.order(:name).pluck(:name)
  end

  def selected_service_name
    return nil if params[:service].blank? || params[:service] == "all"
    params[:service]
  end

  # Removes a specific structured filter from the LQL query string.
  # Used by the view to generate "remove filter" links.
  def remove_filter_from_query(query, filter)
    return query if query.blank?

    tokens = LogSearchParser.new(query).call
    remaining_tokens = []
    raw_tokens = tokenize_query(query)

    raw_tokens.reject! do |token|
      parsed = LogSearchParser.new(token).call
      parsed.filters.any? { |f| f.field == filter.field && f.value == filter.value && f.operator == filter.operator }
    end

    raw_tokens.join(" ")
  end

  private

  # Simple tokenizer matching LogSearchParser's logic
  def tokenize_query(raw)
    tokens = []
    current = +""
    in_quotes = false

    raw.each_char do |ch|
      case ch
      when '"'
        in_quotes = !in_quotes
        current << ch
      when /\s/
        if in_quotes
          current << ch
        else
          tokens << current unless current.empty?
          current = +""
        end
      else
        current << ch
      end
    end
    tokens << current unless current.empty?
    tokens
  end
end
