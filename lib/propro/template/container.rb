class Propro::Template::Container
  def initialize
    @sources = []
    @options = []
    @commands = []
  end

  def source(name)
    @sources << Source.new(name)
  end

  def set(option, value)
    @options << Option.new(option, value)
  end

  def provision(*command)
    @commands.concat(command.flatten.map { |c| Command.new(c) })
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

  def sources_bash
    @sources.each do |source|
    end
  end

  def commands_bash
    @commands.each do |command|
    end
  end
end
