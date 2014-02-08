require 'thor'

module Propro
  class CLI < Thor
    include Thor::Actions

    INIT_TEMPLATES = {
      db: {
        paths: %w[ vps db ],
        desc: 'backend database server'
      },
      app: {
        paths: %w[ vps app ],
        desc: 'frontend application server'
      },
      web: {
        paths: %w[ vps app db ],
        desc: 'standalone web server'
      },
      vagrant: {
        paths: %w[ vagrant ],
        desc: 'standalone Vagrant development VM'
      }
    }

    def self.source_root
      File.join(File.dirname(__FILE__), 'cli/templates')
    end

    desc 'init NAME', 'Creates a Propro script with the file name NAME'
    option :template, aliases: '-t', enum: %w[ db app web vagrant ], default: 'web'
    def init(outname = nil)
      key      = options[:template].to_sym
      outfile  = absolute_path(outname || "#{key}.propro")
      type     = INIT_TEMPLATES[key]
      @paths   = type[:paths]
      @desc    = type[:desc]
      @sources = Package.sources_for_paths('lib', *@paths)
      template 'init.tt', outfile
    end

    desc 'build INPUT', 'Takes a Propro script INPUT and generates a Bash provisioner OUTPUT'
    option :output, aliases: '-o', banner: '<output file name>'
    def build(input)
      infile = absolute_path(input)
      script = Script.load(input).to_bash
      if (output = options[:output])
        File.write(absolute_path(output), script)
      else
        STDOUT << script
      end
    end

    desc 'deploy SCRIPT', 'Builds a Propro script and then executes it remotely'
    option :server,   aliases: '-s', banner: '<server address>'
    option :password, aliases: '-p', banner: '<server password>'
    option :user,     aliases: '-u', banner: '<server user>', default: 'root'
    def deploy(script_path)
      require 'net/ssh'
      require 'net/scp'
      require 'io/console'

      puts "\e[2m#{Propro.banner}\e[0m"

      script   = Script.load(script_path)
      address  = (options[:server] || script.get_server)
      password = (options[:password] || script.get_password || ask_password)
      user     = (options[:user] || script.get_user)
      remote_home = (user == 'root' ? '/root' : "/home/#{user}")
      remote_log_path    = "#{remote_home}/provision.log"
      remote_script_path = "#{remote_home}/provision.sh"
      remote_script_url  = address + remote_script_path

      say_event 'build', script_path
      script_data = StringIO.new(script.to_bash)

      raise ArgumentError, 'no server address has been provided'  if !address
      raise ArgumentError, 'no server password has been provided' if !password

      say_event 'connect', "#{user}@#{address}"
      Net::SSH.start(address, user, password: password) do |session|
        say_event 'upload', "#{script_path} -> #{remote_script_url}"
        session.scp.upload!(script_data, remote_script_path)
        session.exec!("chmod +x #{remote_script_path}")
        session.exec!("touch #{remote_log_path}")
        tail = session.exec("tail -f #{remote_log_path}") do |ch|
          ch.on_data do |ch, data|
            STDOUT.write(data)
            STDOUT.flush
          end
        end

        sleep 1 # ughhhhhh
        say_event 'run', remote_script_url
        puts
        session.exec(remote_script_path)
      end
    rescue IOError # uggghhhhhhhhhh
      say_event 'done', "#{address} is rebooting"
    end

    private

    def say_event(event, msg)
      pad = (7 - event.length)
      label = "#{event.upcase}" + (" " * pad)
      puts "\e[36m\e[1m#{label}\e[0m #{msg}"
    end

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
end
