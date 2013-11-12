require 'docile'
require 'yaml'
require 'erb'

module Shotshare
  module Dsl
    class FilterRule
      attr_reader :allow, :regex

      def process(*args)
        raise Exception.new 'FilterRule#process not implemented.'
      end
    end

    class ProcessRule < FilterRule
      def initialize(allow, regex, &block)
        @allow = allow
        @regex = regex
        @block = block
      end

      def process(psname)
        if psname =~ @regex
          if @block
            @block.call(psname).to_s
          else
            psname
          end
        else
          nil
        end
      end
    end

    class ConfigRule < FilterRule
      def initialize(allow, regex, &block)
        @allow = allow
        @regex = regex
      end

      def process(config_path)
        if config_path =~ @regex
          if @block
            filename = config_path.split('/').last
            tmp_config = File.new("/tmp/shotshare/#{filename}", "w")
            @block.call(tmp_config)
            true
          else
            true
          end
        else
          false
        end
      end
    end

    class ProcessRuleBuilder
      attr_reader :rules
      def initialize
        @rules = []
      end

      def allow(regex, &block)
        @rules << ProcessRule.new(true, regex, block)
      end

      def deny(regex)
        @rules << ProcessRule.new(false, regex)
      end
    end

    class ConfigRuleBuilder
      attr_reader :configs
      def initialize
        @configs = []
      end

      def allow(regex, &block)
        @configs << ConfigRule.new(true, regex, block)
      end

      def deny(regex)
        @configs << ConfigRule.new(false, regex)
      end
    end

  end
end

def process_rules *args, &block
  Docile.dsl_eval(ProcessRuleBuilder.new, &block)
end

def config_rules *args, &block
  Docile.dsl_eval(ConfigRuleBuilder.new, &block)
end

def shots_config(*args)
  if args.first.is_a? File
    config = YAML.load(ERB.new(args.first).result)

  elsif args.first.is_a?(String) and File.exists?(args.first)
    config = YAML.load(ERB.new(args.first).result)

  elsif args.first.is_a? String
    config = YAML.load(args.first)

  elsif args.first.is_a? Hash
    config = args.first

  end
  Shotshare::Config.current.merge!(config)
end
