class Propro::Template::Source
  def initialize(name)
    @name = name.to_s
  end


  def to_bash
    src = ''
    open do |file|
      file.each_line do |line|
        src << line
      end
    end
  end
end
