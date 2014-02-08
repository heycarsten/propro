module Propro
  class Script
    def self.load(file)
      script = new
      script.load_file(file)
      script
    end

    def initialize
      @sources  = []
      @options  = []
      @commands = []
      @server   = nil
      @password = nil
      source :lib
    end

    def load_file(file)
      @file = file
      @file_name = File.basename(@file)
      instance_eval(File.read(file))
    end

    def server(host, opts = {})
      @server   = host
      @password = opts[:password]
      @user     = opts[:user] || 'root'
    end

    def get_server
      @server
    end

    def get_password
      @password
    end

    def get_user
      @user
    end

    def source(src)
      @sources.concat(Package.sources_for_path(src))
    end

    def set(key, value)
      @options << Option.new(key, value)
    end

    def provision(*commands)
      @commands.concat(commands.flatten.map { |c| Command.new(c) })
    end

    def to_bash
      <<-SH
#!/usr/bin/env bash
#{Propro.comment_banner}
#
# Built from: #{@file_name}

unset UCF_FORCE_CONFFOLD
export UCF_FORCE_CONFFNEW="YES"
export DEBIAN_FRONTEND="noninteractive"

#{sources_bash}

# Options from: #{@file_name}
#{options_bash}

function main {
  #{commands_bash}
  finished
  reboot-system
}

main

SH
    end

    private

    def options_bash
      @options.map(&:to_bash).join("\n").strip
    end

    def sources_bash
      @sources.map(&:to_bash).join("\n").strip
    end

    def commands_bash
      @commands.map(&:to_bash).join("\n  ")
    end
  end
end
