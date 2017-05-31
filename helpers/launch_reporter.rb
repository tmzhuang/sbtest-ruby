require 'net/http'
require 'uri'
require 'json'

module LaunchReporter
  class << self
    def submit(report)
      url = "http://localhost:3000/api/v1/launch_reports"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      # Create the request
      req = Net::HTTP::Post.new(uri.to_s)
      req.body = report.to_json
      req['Content-Type'] = 'application/json'

      # Send
      res = http.request(req)
    end
  end
end
