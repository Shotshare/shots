require 'singleton'

module Shotshare

  class ConfigRuleContainer
    include Singleton

    attr_accessor :rules
  end

  class ProcessRuleContainer
    include Singleton

    attr_accessor :rules
  end

  class FilterRule
    attr_reader :allow, :regex

    def initialize(allow, regex, &block)
      @allow = allow
      @regex = regex
      @block = block
    end

    def process(*args)
      raise Exception.new 'FilterRule#process not implemented.'
    end
  end

  class ProcessRule < FilterRule

    def process(psname)
      return nil unless psname =~ @regex
      return nil unless @allow

      return @block.call(psname).to_s if @block
      return psname
    end
  end

  class ConfigRule < FilterRule

    def process(config_path)
      return nil unless config_path =~ @regex
      return nil unless @allow

      # Copy file to tmp directory
      filename = config_path.split('/').last
      tmp_config = "/tmp/shotshare/#{filename}"
      FileUtils.cp config_path, tmp_config

      @block.call(tmp_config) if @block
      return tmp_config
    end

  end
end
