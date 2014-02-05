class Propro::Provisioner::Option
  attr_reader :name

  def initialize(key, value, opts = {})
    @key        = key.to_s.downcase.to_sym
    @value      = value
    @is_literal = opts[:lit] ? true : false
  end

  def name
    @name ||= @key.to_s.upcase
  end

  def value=(val)
    @value = val
  end

  def value
    val = @value || @default
    case val
    when Array
      "\"#{val.join(' ')}\""
    when true
      '"yes"'
    when false
      '"no"'
    else
      @is_literal ? %{'#{val}'} : %{"#{val}"}
    end
  end

  def to_bash
    "#{name}=#{value}"
  end
end
