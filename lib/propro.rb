require 'propro/version'
require 'propro/package'
require 'propro/export'
require 'propro/source'
require 'propro/script'
require 'propro/command'
require 'propro/option'

module Propro
  class Error < StandardError; end

  BANNER = <<'DOC'.chomp
    ____  _________  ____  _________
   / __ \/ ___/ __ \/ __ \/ ___/ __ \
  / /_/ / /  / /_/ / /_/ / /  / /_/ /
 / .___/_/   \____/ .___/_/   \____/
/_/              /_/
DOC

  module_function

  def banner
    BANNER
  end

  def comment_banner
    @comment_banner ||= banner.each_line.map { |l| '# ' + l }.join
  end

  def root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end
