require 'propro/version'
require 'propro/template'
require 'propro/template/command'
require 'propro/template/option'
require 'propro/template/source'
require 'propro/template/container'

module Propro
  module_function
  def shlib_root
    File.join(File.expand_path(File.dirname(__FILE__)), '/propro/shlib')
  end

  def shlibs
    @shlibs ||= Dir[File.join(shlib_root, '**/*.sh')]
  end
end
