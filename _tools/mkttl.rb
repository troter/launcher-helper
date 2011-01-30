# -*- coding:utf-8 -*-

require 'yaml'
$KCODE = "U"

#
# ref: http://sourceforge.jp/magazine/10/01/08/0825239/2
# ref: http://sourceforge.jp/magazine/10/01/18/105235
module TTLMaker

  class SSHConfig
    def initialize(config)
      @dirname = File.dirname(config)
      @config = YAML.load_file(config)
    end

    def run
      @config.each do |data|
        make_ttl(data)
      end
    end

    def make_ttl(data)
      case data['auth']
      when "password"
        make_ttl_password(data)
      when "publickey"
        make_ttl_publickey(data)
      else
      end
    end

    def make_ttl_password(data)
      p data["sshl"]
      options = data["options"].nil? ? "" : " #{data["options"]}";
      macro = <<-EOS
username = '#{data['username']}'
hostname = '#{data['hostname']}'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msg = 'Enter password for user '
strconcat msg username;
strconcat msg '@';
strconcat msg hostname
passwordbox msg 'Get password'

command = hostname
strconcat command ':22 /ssh /auth=password /user='
strconcat command username
strconcat command ' /passwd='
strconcat command inputstr
strconcat command '#{options}'

connect command
      EOS
      macro << "wait '#{data["wait"]}'\n" unless data['wait'].nil?
      macro << "sendln '#{data["command"]}'\n" unless data['command'].nil?
      make_ttl_file(data["name"], macro) 
    end

    def make_ttl_publickey(data)
      ssh_l = data["ssh_l"].nil? ? "" : " /ssh-L#{data["ssh_l"]}";
      options = data["options"].nil? ? "" : " #{data["options"]}";
      macro = <<-EOS
username = '#{data['username']}'
hostname = '#{data['hostname']}'
keyfile = '#{data['keyfile']}'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msg = 'Enter publickey passphrase for user '
strconcat msg username;
strconcat msg '@';
strconcat msg hostname
passwordbox msg 'Get password'

command = hostname
strconcat command ':22 /ssh /auth=publickey /user='
strconcat command username
strconcat command ' /keyfile='
strconcat command keyfile
strconcat command ' /passwd='
strconcat command inputstr
strconcat command '#{options}'

connect command
      EOS

      macro << "wait '#{data["wait"]}'\n" unless data['wait'].nil?
      macro << "sendln '#{data["command"]}'\n" unless data['command'].nil?
      make_ttl_file(data["name"], macro)
    end

    def make_ttl_file(name, macro)
      puts "============================================================"
      puts "FILE: #{@dirname}/#{name}.ttl"
      puts "------------------------------------------------------------"
      puts "CONTENT"
      puts "------------------------------------------------------------"
      puts macro
      puts "============================================================"

      File.open("#{@dirname}/#{name}.ttl", "w") do |f|
        f << macro
      end
    end
  end

  def self.run
    Dir["../**/ttl.yml"].each do |config|
      TTLMaker::SSHConfig.new(config).run
    end
  end
end

TTLMaker.run
