require 'thor'

class Propro::CLI < Thor
  include Thor::Actions

  def self.source_root
    File.join(File.dirname(__FILE__), 'cli/templates')
  end

  desc 'init NAME', 'Creates a Propro script with the file name NAME'
  def init(name = nil)
    @packages = Propro.packages
    file = if name
      absolute_path(name)
    else
      File.join(Dir.pwd, 'provision.propro')
    end
    template 'propro.tt', file
  end

  desc 'build INPUT', 'Takes a Propro script INPUT and generates a Bash provisioner OUTPUT'
  option :output, aliases: :o, banner: '<output file name>'
  def build(input)
    infile = absolute_path(input)
    script = Propro::Provisioner::Script.load(input).to_bash
    if (output = options[:output])
      File.write(absolute_path(output), script)
    else
      STDOUT << script
    end
  end

  desc 'deploy SCRIPT', 'Builds a Propro script and then executes it remotely'
  option :server,   aliases: :s, banner: '<server address>'
  option :password, aliases: :p, banner: '<server password>'
  option :user,     aliases: :u, banner: '<server user>', default: 'root'
  def deploy(script_path)
    require 'net/ssh'
    require 'net/scp'
    require 'io/console'

    script   = Propro::Provisioner::Script.load(script_path)
    address  = (options[:server] || script.get_server)
    password = (options[:password] || script.get_password || ask_password)
    user     = (options[:user] || script.get_user)
    home     = user == 'root' ? '/root' : "/home/#{user}"

    say "Compiling Propro script: #{script_path}", :cyan
    script_data = StringIO.new(script.to_bash)

    raise ArgumentError, 'no server address has been provided'  if !address
    raise ArgumentError, 'no server password has been provided' if !password

    say "Connecting to #{user}@#{address}", :cyan
    Net::SSH.start(address, user, password: password) do |session|

      say "Uploading Propro script", :cyan
      session.scp.upload!(script_data, "#{home}/provision.sh")
      session.exec!("chmod +x #{home}/provision.sh")
      session.exec!("touch #{home}/provision.log")
      tail = session.exec("tail -f #{home}/provision.log") do |ch|
        ch.on_data do |ch, data|
          STDOUT.write(data)
          STDOUT.flush
        end
      end

      say 'Starting Propro', :cyan
      session.exec("#{home}/provision.sh") do |ch|
        ch.on_close do |ch|
          tail.close
          session.close
        end
      end
    end

    say "Disconnected from #{user}@#{address}", :cyan
  end

  private

  def ask_password
    STDIN.noecho do
      ask 'password:'
    end
  end

  def absolute_path(path)
    if path[0] == '/'
      path
    else
      File.join(Dir.pwd, path)
    end
  end
end
