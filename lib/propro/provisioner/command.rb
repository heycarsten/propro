class Propro::Provisioner::Command
  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end

  def function_name
    @function_name ||= "provision-#{name.gsub(/\/\_/, '-')}"
  end

  def to_bash
    function_name
  end
end
