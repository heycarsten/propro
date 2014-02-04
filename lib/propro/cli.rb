require 'thor'

class Propro::CLI < Thor
  include Thor::Actions
  source_root File.join(Propro.cli_root, 'templates')

  desc :init, 'Creates a propro provisioning template'
  def init
    @packages = Propro.packages
    template 'propro.tt', File.join(Dir.pwd, 'provision.propro')
  end

  desc :build, 'Builds a bash script based on Propro file'
  def build
  end
end
