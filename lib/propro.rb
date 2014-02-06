require 'propro/version'
require 'propro/package'
require 'propro/package/export'
require 'propro/package/source'
require 'propro/provisioner'
require 'propro/provisioner/script'
require 'propro/provisioner/command'
require 'propro/provisioner/option'

module Propro
  class Error < StandardError; end

  BANNER = <<'DOC'
    ____  _________  ____  _________
   / __ \/ ___/ __ \/ __ \/ ___/ __ \
  / /_/ / /  / /_/ / /_/ / /  / /_/ /
 / .___/_/   \____/ .___/_/   \____/
/_/              /_/
DOC

  COMMENT_BANNER = BANNER.each_line.map { |l| "# #{l.chomp}" }.join("\n")

  module_function

  def root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end
