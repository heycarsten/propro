class Propro::Package::Export
  EXPORT_BEGIN  = 'export '
  COMMENT_RANGE = /#.*/

  def self.parse(line)
    line        = line.sub(EXPORT_BEGIN, '')
    name, value = line.split('=', 2)

    # Remove comments
    value.sub!(COMMENT_RANGE, '')
    value.strip!

    case value[0]
    when '"'
      value[0]  = ''
      value[-1] = ''
      is_single_quote = false
    when "'"
      value[0]  = ''
      value[-1] = ''
      is_single_quote = true
    else
      value
    end

    new name, default: value
  end

  def initialize(name, opts = {})
    @name    = name.to_s.upcase
    @default = opts[:default]
  end

  def key
    @key ||= @name.downcase.to_sym
  end

  def to_ruby
    "set #{key.inspect}, #{default.inspect}"
  end

  def default
    cast(@default)
  end

  protected

  def cast(val)
    case val
    when /\A\-{0,1}[0-9]+\Z/
      val.to_i
    when /\A\-{0,1}[0-9]+\.[0-9]+\Z/
      val.to_f
    when ''
      nil
    when / /
      val.split(' ')
    when 'yes'
      true
    when 'no'
      false
    else
      val
    end
  end

end
