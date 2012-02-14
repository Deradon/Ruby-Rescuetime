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
      @debug  = options[:debug]
      @http   = Net::HTTP.new(API_HOST, 443)
      @http.use_ssl = true

      @email    = options[:email]
      @password = options[:password]
    end

    # Convert array of app objects to yamldata
    def prepare_data(apps)
      data = "---\n"
      apps.each { |app| data += app.to_upload_data }
      debug "[DATA TO SAVE]" do puts data end
      # YAML::dump(apps)

      return data
    end

    # Service available?
    def connection_alive?
      resp = @http.get(API_HANDSHAKE_PATH)
      resp.code == "200"
    end

    # Upload yamldata
    def upload(options = {})
      hash = {  :email    => @email,
                :password => @password,
                :yamldata => options[:yamldata] }

      data = []
      hash.each do |key, value|
        data << "#{key.to_s}=#{CGI.escape(value)}" if value
      end

      data = data.join("&")
      debug "[YAMLDATA]" do puts data end

      headers = { 'User-agent' => USER_AGENT }
      resp    = @http.post(API_UPLOAD_PATH, data, headers)
      debug "[UPLOAD]" do p resp.body end

      return (resp.code == "200" && !resp.body["<error>"])
    end

    # Handshake with login credentials
    def handshake
      data    = "email=#{@email}&password=#{@password}"
      headers = { 'User-agent' => USER_AGENT }
      resp    = @http.post(API_HANDSHAKE_PATH, data, headers)
      debug "[HANDSHAKE]" do p resp.body end

      return (resp.code == "200" && !resp.body["login failure"])
    end
  end
end

