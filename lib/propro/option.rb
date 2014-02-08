module Propro
  class Option
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
      case @value
      when Array
        %{"#{val.join(' ')}"}
      when true
        %{"yes"}
      when false
        %{"no"}
      else
        @is_literal ? %{'#{@value}'} : %{"#{@value}"}
      end
    end

    def to_bash
      "#{name}=#{value}"
    end
  end
end
