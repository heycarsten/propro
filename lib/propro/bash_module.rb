class Propro::BashModule
  def initialize(name)
    @name = name.to_s
    @options = []
    @src = ''
    parse
  end

  def file_path
    File.join(Propro.shlib_root, "#{@name}.sh")
  end

  def load
    @src = ''
    File.open(file_path) do |file|
      file.each_line do |line|
        case
        # skip shebangs
        when line.include('#!/')
          next
        # collect exported options from bash modules
        when line =~ /\Aexport ([A-Z0-9_]+)=['"]{0,1}(.*)['"]{0,1}\Z/
          @options << Option.new($1.downcase.to_sym, default: $2)
          src << line
        else
          src << line
        end
      end
    end
  end

  end

  def parse
    @payload = ''
    File.opne
  end

  def options
  end

  def to_bash
  end
end
