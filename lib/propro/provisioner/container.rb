class Propro::Provisioner::Container
  EXPAND_PACKAGES = {
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
    container = new
    container.instance_exec(file)
    container
  end

  def initialize
    @packages = []
    @options  = []
    @commands = []
  end

  def source(src)
    if (expands = EXPAND_PACKAGES[src])
      @packages.concat(expands.map { |s| Package.new(s) })
    else
      @packages << Package.new(src)
    end
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
set -e
set -u
exec &> /root/full_provision.log

#{sources_bash}

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
    @sources.map(&:to_bash).join("\n")
  end

  def commands_bash
    @commands.map(&:to_bash).join("\n  ")
  end
end
