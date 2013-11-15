require 'singleton'
module Shotshare
  class Config
    include Singleton

    DEFAULT = {
      api_key: ENV['SHOTSHARE_API_KEY'],
      tmp_dir: '/tmp/shotshare'
    }

    attr_accessor :current
    attr_reader :default

    def initialize
      @default = DEFAULT
      @current = @default
    end

    class << self
      def load_config(path)
        shots_config(path)
      end
    end

  end
end
