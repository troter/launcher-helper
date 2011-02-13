# -*- coding:utf-8 -*-

require 'yaml'
$KCODE = "U"

module LinkMaker

  class RedirectMaker
    def initialize(config)
      @dirname = File.dirname(config)
      @config = YAML.load_file(config)
    end

    def run
      @config.each do |data|
        make_link(data)
      end
    end

    def make_link(data)
      name = data['name']
      html = <<EOS
<html>
<meta http-equiv="REFRESH" content="0;URL=#{data['url']}">
</html>
EOS
      File.open("#{@dirname}/#{name}.html", "w") do |f|
        f << html
      end
    end
  end

  def self.run
    Dir["../**/link.yml"].each do |config|
      LinkMaker::RedirectMaker.new(config).run
    end
  end
end

LinkMaker.run
