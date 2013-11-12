require 'rest-client'

module Shotshare

  class Submission

    def initialize
      @submission_key = nil
    end

    def prepare
      result = RestClient.post URL + '/api/submissions'
      sub = JSON.parse(result)
      @submission_key = sub['key']
    end

    def add_screenshot screenshot_file

    end

  end

end
