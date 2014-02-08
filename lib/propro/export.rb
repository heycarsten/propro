module Propro
  class Export
    TAG_SPECIFY   = '@specify'
    TAG_REQUIRE   = '@require'
    EXPORT_BEGIN  = 'export '
    COMMENT_RANGE = /#(.*)\Z/
    DQUO          = '"'
    SQUO          = '\''
    EQ            = '='
    ZERO_STRING   = ''
    INTEGER_RE    = /\A\-{0,1}[0-9]+\Z/
    DECIMAL_RE    = /\A\-{0,1}[0-9]+\.[0-9]+\Z/
    SPACE_RE      = / /
    YES           = 'yes'
    NO            = 'no'

    def self.parse(line)
      is_literal   = false
      is_specified = false
      is_required  = false
      comment      = nil
      line         = line.sub(EXPORT_BEGIN, ZERO_STRING)
      name, value  = line.split(EQ, 2)

      if value =~ COMMENT_RANGE
        metacomment = $1
        is_specified = true if metacomment.sub!(TAG_SPECIFY, ZERO_STRING)
        is_required  = true if metacomment.sub!(TAG_REQUIRE, ZERO_STRING)
        metacomment.strip!

        if metacomment != ZERO_STRING
          comment = metacomment
        end
      end

      value.sub!(COMMENT_RANGE, ZERO_STRING)
      value.strip!

      case value[0]
      when DQUO
        value[0]  = ZERO_STRING
        value[-1] = ZERO_STRING
      when SQUO
        is_literal = true
        value[0]   = ZERO_STRING
        value[-1]  = ZERO_STRING
      end

      new name,
        default:      value,
        is_literal:   is_literal,
        is_specified: is_specified,
        is_required:  is_required,
        comment:      comment
    end

    def initialize(name, opts = {})
      @name         = name.to_s.upcase
      @default      = opts[:default]
      @is_literal   = opts[:is_literal]
      @is_specified = opts[:is_specified]
      @is_required  = opts[:is_required]
      @comment      = opts[:comment]
    end

    def key
      @key ||= @name.downcase.to_sym
    end

    def to_ruby
      args = []
      args << key.inspect
      args << default.inspect
      args << "lit: true" if @is_literal
      if @comment
        "set #{args.join(', ')} # #{@comment}"
      else
        "set #{args.join(', ')}"
      end
    end

    def default
      cast(@default)
    end

    def is_literal?
      @is_literal
    end

    def is_specified?
      @is_specified
    end

    def is_required?
      @is_required
    end

    protected

    def cast(val)
      case val
      when INTEGER_RE
        val.to_i
      when DECIMAL_RE
        val.to_f
      when ZERO_STRING
        nil
      when SPACE_RE
        val.split(' ')
      when YES
        true
      when NO
        false
      else
        val
      end
    end
  end
end
