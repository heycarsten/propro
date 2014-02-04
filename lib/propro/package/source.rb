class Propro::Package::Source
  attr_reader :exports, :name, :src

  EXPORT_BEGIN = 'export '

  def initialize(name)
    @name = name.to_s
    @exports = []
    @src = ''
    load
  end

  def file_name
    "#{@name}.sh"
  end

  def file_path
    File.join(Propro.packages_root, file_name)
  end

  def load
    @src = ''
    File.open(file_path) do |file|
      file.each_line do |line|
        case
        # skip comments
        when line.start_with?('#')
          next
        # collect exported variables from bash modules
        when line.start_with?(EXPORT_BEGIN)
          @exports << Propro::Package::Export.parse(line)
          @src << line.sub(EXPORT_BEGIN, '')
        else
          @src << line
        end
      end
    end
    @src
  end

  def to_bash
<<-SH
# Propro module: #{file_name}
#{@src}

SH
  end
end
