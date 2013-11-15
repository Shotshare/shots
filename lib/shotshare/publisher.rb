require 'rest_client'
require 'json'

module Shotshare
  class Publisher

    def initialize(apikey)
      @apikey = apikey
    end

    def register email, username
      RestClient.post URL + "/api/register", \
        email: email, username: username
    end

    def prepare_submission
      result = RestClient.post URL + "/api/submissions", \
        {}, {Authorization: "Token token=#{@apikey}"}
      @submission_key = JSON.parse(result)['key']
      @submission_key
    end

    def publish_submission
      upload_to_submission nil, nil, nil, true
    end

    def upload_screenshot file
      return nil unless @submission_key
      upload_to_submission File.new(file, 'rb'), 'screenshot'
    end

    def upload_program program
      return nil unless @submission_key

      upload_to_submission nil, 'program', {'program' => program }
    end

    def upload_configuration file
      return nil unless @submission_key

      upload_to_submission File.new(file, 'rb'), 'config'
    end

    private
    def upload_to_submission file=nil, type=nil, params=nil, finalize=false
      return nil unless @submission_key

      params ||= {}
      params[:file] = file if file
      params[:finalize] = true if finalize

      result = RestClient.put URL + "/api/submissions/#{@submission_key}?type=#{type}", params, {Authorization: "Token token=#{@apikey}"}
      JSON.parse(result)['key']
    end

  end
end
