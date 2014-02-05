class Propro::Provisioner::Script
  EXPAND_SOURCES = {
    core: [
      'core/propro',
      'core/ubuntu'
    ],
    system: [
      'system',
      'system/sources'
    ],
    app: [
      'app',
      'app/rvm',
      'app/pg',
      'app/sidekiq',
      'app/puma',
      'app/puma/nginx'
    ],
    db: [
      'db',
      'db/pg'
    ]
  }

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
  end

  def load_file(file)
    @file = file
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
    if (expands = EXPAND_SOURCES[src])
      @sources.concat(expands.map { |s| Propro::Package::Source.new(s) })
    else
      @sources << Propro::Package::Source.new(src)
    end
  end

  def set(key, value)
    @options << Propro::Provisioner::Option.new(key, value)
  end

  def provision(*commands)
    @commands.concat(commands.flatten.map { |c| Propro::Provisioner::Command.new(c) })
  end

  def to_bash
    <<-SH
#!/usr/bin/env bash
set -e
set -u
exec &> /root/full_provision.log

#{sources_bash}

# #{@file}
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
    @options.map(&:to_bash).join("\n")
  end

  def sources_bash
    @sources.map(&:to_bash).join
  end

  def commands_bash
    @commands.map(&:to_bash).join("\n  ")
  end
end
