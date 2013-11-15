module Shotshare
  module Dsl
    class ProcessRuleBuilder
      attr_reader :rules
      def initialize
        @rules = []
      end

      def allow(regex, &block)
        regex = Regexp.new(regex) if regex.is_a? String
        @rules << ProcessRule.new(true, regex, &block)
      end

      def deny(regex)
        regex = Regexp.new(regex) if regex.is_a? String
        @rules << ProcessRule.new(false, regex)
      end

      def build
        @rules
      end
    end

    class ConfigRuleBuilder
      attr_reader :configs
      def initialize
        @configs = []
      end

      def allow(regex, &block)
        regex = Regexp.new(regex) if regex.is_a? String
        @configs << ConfigRule.new(true, regex, &block)
      end

      def deny(regex)
        regex = Regexp.new(regex) if regex.is_a? String
        @configs << ConfigRule.new(false, regex)
      end

      def build
        @configs
      end
    end

  end
end
