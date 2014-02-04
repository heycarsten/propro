class Propro::Provisioner::Option
  attr_reader :name

  def initialize(key)
    @key = key.to_s.downcase.to_sym
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
      "\"#{val}\""
    end
  end

  def to_bash
    "#{name}=#{value}"
  end
end
