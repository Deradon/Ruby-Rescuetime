module Rescuetime
  class Loop
    include Rescuetime::Debug

    attr_reader :config

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

      debug! if @config.debug?

      debug "[OPTIONS]" do p options end

      @apps = []
      @current_app = nil
      @uploader = Rescuetime::Uploader.new( :debug    => debug?,
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
        puts "\n[OFFLINE-MODE]"
      else
        upload!
        upload!("failure")
      end

      Signal.trap("INT") do
        shutdown! if running?
      end

      self.run
    end

    def running!(running = true)
      @running = running
    end

    def running?
      @running == true
    end

    # Handler called if 'Ctrl + C' is pressed
    def shutdown!
      running!(false)
      @apps << @current_app

      backup!
      upload!
      exit
    end

    # Run the loop
    def run
      running!
      @current_app = Application.create(:debug => debug?)

      while true
        sleep 1 # TODO: move to config
        focus_changed if @current_app.finished? || backup?
      end
    end



    ### BACKUP DATA ### (may be moved)

    # NEW && UNTESTED
    def last_backup_at
      @last_backup_at ||= Time.now
    end

    # NEW && UNTESTED
    def seconds_since_last_backup
      Time.now - last_backup_at
    end

    # NEW && UNTESTED
    # TODO: read from config
    def backup?
      @apps.length > 100 || seconds_since_last_backup > 30*60
    end

    # NEW && UNTESTED
    def backup!
      debug "[BACKUP]"

      @last_backup_at = Time.now
      timestamp = @last_backup_at.to_i

      path = File.join(config.path, "upload", "todo", "#{timestamp}.yaml")
      FileUtils.mkdir_p(File.dirname(path))

      File.open(path, 'w') do |f|
        f.write(Rescuetime::Application.to_yaml(@apps))
      end

      @apps = []
    end

    # NEW && UNTESTED
    def upload!(mode = "todo") # possible modes: todo, failure
      path  = File.join(config.path, "upload", mode, "*.yaml")
      files = Dir.glob(path)

      success_path = File.join(config.path, "upload", "success")
      failure_path = File.join(config.path, "upload", "failure")

      # Make sure directories exist
      FileUtils.mkdir_p(success_path)
      FileUtils.mkdir_p(failure_path)

      debug "[UPLOAD] #{files.count} files"
      files.each_with_index do |f, i|
        debug "#{f} (#{i})"
        file      = File.open(f, "rb")
        yamldata  = file.read
        file.close
        success   = @uploader.upload(:yamldata => yamldata)

        # CHECK: may another solution for base_name exist?
        base_name = f.split("/").last

        path = success ? success_path : failure_path
        path = File.join(path, base_name)

        # HACK: don't copy if mode == failure and failure again
        FileUtils.mv(f, path) unless !success && mode == "failure"
      end
    end



    private
    # Old app lost focus, get new one
    def focus_changed
      backup! if backup?

      @apps << @current_app
      debug "\n[OLD FOCUS]" do
        puts "#{@current_app.to_s}:\n#{@current_app.active_time} seconds alive\n\n"
      end
      @current_app = Application.create(:debug => debug?)
      puts "#{@current_app}"
    end
  end
end

