class Propro::Provisioner::Command
  def initialize(name)
    @name = name.to_s
  end

  def function_name
    @function_name ||= "provision-#{name.gsub(/\/\_/, '-')}"
  end

  def to_bash
    "#{function_name}"
  end
end
