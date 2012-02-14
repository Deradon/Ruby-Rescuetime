module Rescuetime
  class Loop
    include Rescuetime::Debug

    # =Creates and run a new Rescuetime::Loop:
    #   Rescuetime::Loop.new({
    #     :email    => "foo@example.com",
    #     :password => "bar",
    #     :config   => "/home/foobar/rescue/bar.yml",
    #     :path     => "/home/foobar/rescue/data" ,
    #     :debug    => true
    #   })
    def initialize(options = {})
      options = {
        :debug    => false,
        :email    => nil,
        :password => nil,
        :config   => nil,
        :path     => nil
      }.merge(options)

      @config = Config.new(options)

      @debug  = @config.debug?
      debug "[OPTIONS]" do p options end

      @apps   = []
      @current_app = nil
      @uploader = Rescuetime::Uploader.new( :debug    => @debug,
                                            :email    => @config.email,
                                            :password => @config.password)

      debug "[LOGIN - DATA]" do
        puts "#{@config.email}:#{@config.password}"
      end

      if !@uploader.handshake
        puts "[LOGIN FAILED]"
        puts "Please call ruby-rescuetime with correct login credentials."
        puts " * ruby-rescuetime --email foo@example.com --password secret\n OR"
        puts " * edit: #{@config.location}"
        exit
      end

      @running = true
      Signal.trap("INT") do
        shutdown if @running
      end

      self.run
    end

    def running?
      @running == true
    end

    # Handler called if 'Ctrl + C' is pressed
    def shutdown
      @running = false
      @apps << @current_app
      yamldata  = @uploader.prepare_data(@apps)
      success   = @uploader.upload(:yamldata => yamldata)
      raise "Upload failed" unless success

      exit
    end

    # Run the loop
    def run
      @current_app = Application.create(:debug => @debug)
      puts "[FOCUS] #{@current_app}"

      while true
        sleep 1 # TODO: move to config
        new_focus unless @current_app.active?
      end
    end



    private
      # Old app lost focus, get new one
      def new_focus
        @apps << @current_app
        debug "[OLD FOCUS]" do
          puts "#{@current_app.to_s}: #{@current_app.active_time} seconds alive\n"
        end
        @current_app = Application.create(:debug => @debug)
        puts "[FOCUS] #{@current_app}"
      end
  end
end

