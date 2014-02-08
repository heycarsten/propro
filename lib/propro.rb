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

  # <3 <3 <3 Lifted from Minitest::Pride <3 <3 <3
  # https://github.com/seattlerb/minitest/blob/master/lib/minitest/pride_plugin.rb
  def color_banner
    @color_banner ||= begin
      if /^xterm|-256color$/ =~ ENV['TERM']
        pi3    = Math::PI / 3
        colors = (0...(6 * 7)).map { |n|
          n *= 1.0 / 6
          r  = (3 * Math.sin(n          ) + 3).to_i
          g  = (3 * Math.sin(n + 2 * pi3) + 3).to_i
          b  = (3 * Math.sin(n + 4 * pi3) + 3).to_i
          36 * r + 6 * g + b + 16
        }
        banner.each_line.map { |line|
          line.each_char.with_index.map { |chr, i|
            "\e[38;5;#{colors[i]}m#{chr}\e[0m"
          }.join
        }.join
      else
        "\e[2m#{banner}\e[0m"
      end
    end
  end

  def comment_banner
    @comment_banner ||= banner.each_line.map { |l| '# ' + l }.join
  end

  def root
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end
