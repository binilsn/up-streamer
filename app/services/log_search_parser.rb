class LogSearchParser
  StructuredFilter = Struct.new(:field, :operator, :value, keyword_init: true)

  RECOGNIZED_FIELDS = %w[
    service level host message error_code
    status env path duration trace_id request_id tag
  ].freeze

  COMPARISON_OPS = %w[>= <= > <].freeze
  DEFAULT_OP = "=".freeze

  Result = Struct.new(:filters, :plain_text, keyword_init: true) do
    def any?
      filters.any?
    end
  end

  def initialize(query_string)
    @query = query_string.to_s.strip
  end

  def call
    tokens = self.class.tokenize(@query)
    filters = []
    remaining = []

    tokens.each do |token|
      if (parsed = parse_structured_token(token))
        filters << parsed
      else
        remaining << token
      end
    end

    Result.new(filters: filters, plain_text: remaining.join(" "))
  end

  def self.tokenize(raw)
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

  private

  def parse_structured_token(token)
    field, remainder = extract_field(token)
    return nil unless field

    operator, value = extract_operator_and_value(remainder)
    return nil if value.nil? || value.empty?

    StructuredFilter.new(field: field, operator: operator, value: unquote(value))
  end

  def extract_field(token)
    idx = token.index(":")
    return nil unless idx
    return nil if idx == 0

    field = token[0...idx]
    remainder = token[(idx + 1)..]

    return nil unless RECOGNIZED_FIELDS.include?(field)

    [ field, remainder ]
  end

  def extract_operator_and_value(remainder)
    COMPARISON_OPS.each do |op|
      if remainder.start_with?(op)
        return [ op, remainder[op.length..] ]
      end
    end
    [ DEFAULT_OP, remainder ]
  end

  def unquote(value)
    value.start_with?('"') && value.end_with?('"') ? value[1..-2] : value
  end
end
