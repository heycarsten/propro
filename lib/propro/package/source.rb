class Propro::Package::Source
  attr_reader :name

  EXPORT_BEGIN  = 'export '
  COMMENT_BEGIN = '#'

  def initialize(name)
    @name    = name.to_s
    @exports = []
    @src     = ''
    load
  end

  def file_name
    "#{@name}.sh"
  end

  def file_path
    File.join(Propro.packages_root, file_name)
  end

  def load
    File.open(file_path) do |file|
      file.each_line { |line| load_line(line) }
    end
  end

  def specified_exports
    @specified_exports ||= begin
      exports.select { |e| e.is_required? || e.is_specified? }
    end
  end

  def exports
    @exports.sort { |a, b|
      case
      when b.is_required?
        1
      when b.is_specified?
        0
      else
        -1
      end
    }
  end

  def to_bash
<<-SH
# Propro module: #{file_name}
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
      @exports << Propro::Package::Export.parse(line)
      @src << line.sub(EXPORT_BEGIN, '')
    else
      # pass-through
      @src << line
    end
  end
end
