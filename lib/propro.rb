require 'propro/version'
require 'propro/package'
require 'propro/package/export'
require 'propro/package/source'
require 'propro/provisioner'
require 'propro/provisioner/command'
require 'propro/provisioner/container'
require 'propro/provisioner/option'

module Propro
  class Error < StandardError; end

  module_function

  def root
    File.expand_path(File.dirname(__FILE__))
  end

  def cli_root
    File.join(root, 'propro/cli')
  end

  def packages_root
    File.expand_path(File.join(root, '../ext/bash'))
  end

  def package_files
    @package_files ||= Dir[File.join(packages_root, '**/*.sh')]
  end

  def packages
    files = Package::SORT_PACKAGES.dup
    package_files.each do |f|
      name = f.match(%r{/ext/bash/([a-z0-9_\-/]+)\.sh})[1]
      files.push(name) if !files.include?(name)
    end
    @packages ||= files.map do |f|
      Package::Source.new(f)
    end
  end
end
