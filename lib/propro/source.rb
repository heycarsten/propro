module Propro
  class Source
    attr_reader :name, :provisioner

    EXPORT_BEGIN         = 'export '
    COMMENT_BEGIN        = '#'
    IS_LIBRARY_BEGIN     = 'lib/'
    FUNC_PROVISION_BEGIN = 'function provision-'
    FUNC_PROVISION_NAME_RANGE = /\Afunction provision\-([a-z\-]+)/

    def initialize(name)
      @name          = name.to_s
      @exports       = []
      @can_provision = false
      @is_library    = name.start_with?(IS_LIBRARY_BEGIN)
      @src           = ''
      load
    end

    def file_name
      "#{@name}.sh"
    end

    def file_path
      File.join(Propro::Package.root, file_name)
    end

    def load
      File.open(file_path) do |file|
        file.each_line { |line| load_line(line) }
      end
    end

    def can_provision?
      @can_provision
    end

    def is_library?
      @is_library
    end

    def specified_exports
      @specified_exports ||= begin
        exports.select { |e| e.is_required? || e.is_specified? }
      end
    end

    def exports
      @exports.sort { |a, b|
        case
          when b.is_required? then 1
          when b.is_specified? then 0
          else -1
        end
      }
    end

    def to_bash
      <<-SH
# Propro package: #{file_name}
#{@src}
      SH
    end

    protected

    def load_line(line)
      case
      when line.start_with?(COMMENT_BEGIN)
        # skip comments
      when line.start_with?(EXPORT_BEGIN)
        # collect exported variables from bash modules
        @exports << Export.parse(line)
        @src << line.sub(EXPORT_BEGIN, '')
      when line.start_with?(FUNC_PROVISION_BEGIN)
        @can_provision = true
        path = line.match(FUNC_PROVISION_NAME_RANGE)[1]
        @provisioner = path.gsub('-', '/')
        @src << line
      else
        # pass-through
        @src << line
      end
    end
  end
end
