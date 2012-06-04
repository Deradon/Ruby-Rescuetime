module Rescuetime
  class Uploader
    include Rescuetime::Debug
    require 'net/http'
    require 'net/https'
    require 'cgi'
    #require 'yaml'

    API_HOST            = "api.rescuetime.com"
    API_HANDSHAKE_PATH  = "/api/handshake"
    API_UPLOAD_PATH     = "/api/userlogs"

    # TODO: use own USER_AGENT
    USER_AGENT  = 'RescueTimeLinuxUploader/0.91 +https://launchpad.net/rescuetime-linux-uploader'

    # Usage:
    #   Rescuetime::Uploader.new({
    #     :email    => "foo@example.com",
    #     :password => "bar",
    #     :debug    => false
    #   })
    def initialize(options = {})
      debug! if options[:debug]

      @http   = Net::HTTP.new(API_HOST, 443)
      @http.use_ssl = true

      @email    = options[:email]
      @password = options[:password]
    end

    # Service available?
    def connection_alive?
      resp = @http.get(API_HANDSHAKE_PATH)
      resp.code == "200"
    end

    # =Uploads yaml-formatted data
    # ==Usage:
    #   @uploader.upload(:yamldata => yamldata)
    # ==Returns:
    #   true if upload successful, false otherwise
    def upload(options = {})
      hash = { :email    => @email,
               :password => @password,
               :yamldata => options[:yamldata] }

      data = []
      hash.each do |key, value|
        data << "#{key.to_s}=#{CGI.escape(value)}" if value
      end

      data = data.join("&")
      debug "[YAMLDATA]" do puts data end

      headers = { 'User-agent' => USER_AGENT }

      begin
        resp = @http.post(API_UPLOAD_PATH, data, headers)
      rescue
        return false
      end

      debug "[UPLOAD]" do puts resp.body end

      return (resp.code == "200" && !resp.body["<error>"])
    end

    # =Handshake with login credentials
    # ==Returns:
    #   true if handshake successful, false otherwise
    def handshake
      data    = "email=#{@email}&password=#{@password}"
      headers = { 'User-agent' => USER_AGENT }

      begin
        resp = @http.post(API_HANDSHAKE_PATH, data, headers)
      rescue SocketError
        return false
      end

      debug "[HANDSHAKE]" do puts resp.body end

      return (resp.code == "200" && !resp.body["login failure"])
    end
  end
end

