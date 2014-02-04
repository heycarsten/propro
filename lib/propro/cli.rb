require 'propro'
require 'thor'

class Propro::CLI < Thor
  include Thor::Actions

  desc :init, 'Creates a propro provisioning template in the current directory'
  def init
    template 'templates/template.propro.tt'
  end
end
