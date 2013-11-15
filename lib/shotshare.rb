require 'docile'
require 'yaml'
require 'erb'

module Shotshare
  # Constants
  URL = 'http://10.10.45.188:3000'
  #URL = 'http://fast-beyond-6220.herokuapp.com'
end

require_relative './shotshare/config'
require_relative './shotshare/rules'
require_relative './shotshare/dsl'
require_relative './shotshare/publisher'
require_relative './shotshare/shots'


# Global methods for dsl
def process_rules *args, &block
  Shotshare::ProcessRuleContainer.instance.rules = \
    Docile.dsl_eval(Shotshare::Dsl::ProcessRuleBuilder.new, &block).build
end

def config_rules *args, &block
  Shotshare::ConfigRuleContainer.instance.rules = \
    Docile.dsl_eval(Shotshare::Dsl::ConfigRuleBuilder.new, &block).build
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
  Shotshare::Config.instance.current.merge!(config)
end

