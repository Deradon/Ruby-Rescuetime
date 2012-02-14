module Rescuetime
  class Application
    include Rescuetime::Debug

    def self.current_application_name
      cmd = <<-CMD
        xprop -id `xprop -root |
          awk '/_NET_ACTIVE_WINDOW/ {print $5; exit;}'` |
          awk -F = '/WM_CLASS/ {print $2; exit;}'|
          awk '{print $2}' |
          sed 's/^"//g' |
          sed 's/"$//g'
      CMD
      `#{cmd}`.strip
    end

    def self.current_window_title
      cmd = <<-CMD
        xprop -id `xprop -root |
          awk '/_NET_ACTIVE_WINDOW/ {print $5; exit;}'` |
          awk -F = '/^WM_NAME/ {print $2; exit;}' |
          sed -e's/^ *"//g' |
          sed -e's/\\"$//g'
      CMD
      `#{cmd}`.strip
    end

    attr_reader :name, :title, :created_at, :finished_at
    #protected_class_method :new

    # TODO
    def self.create(options = {})
      name  = options[:name] || self.current_application_name
      klass = Rescuetime::Extension.get(name) || self
      klass.new(options)
    end



    # Constructor: Call with {:debug => true} to get debug messages
    def initialize(options = {})
      @debug      = options[:debug]
      @name       = options[:name]  || current_application_name
      @title      = options[:title] || current_window_title

      @created_at   = Time.now
      @finished_at  = nil
      @active       = true
    end

    def name
      @name.gsub("\000", "").gsub("'", "`")
    end

    def title
      @title.gsub("\000", "").gsub("'", "`")
    end

    # Returns: Time of where app where detected to not be active anymore, or
    # Time now if not finished yet
    def finished_at
      (@finished_at || Time.now).to_s[0..-7] # HACK: to remove offset (e.g. + 01:00)
    end

    def created_at
      (@created_at || Time.now).to_s[0..-7] # HACK: to remove offset (e.g. + 01:00)
    end

    # Returns: boolean, if application is still active window
    def active?
      return @active unless @active

      @active = @name  == current_application_name &&
                @title == current_window_title
      finish! unless @active

      return @active
    end

    def finished?
      !active?
    end

    # Returns difference between StartTime and now if still active, or
    # StartTime and FinishedTime if not ative anymore
    def active_time
      (active?) ? (Time.now - @created_at) : (@finished_at - @created_at)
    end

    def to_s
      "#{name}:#{title}:#{extended_info}"
    end

    def extended_info
      (@extended_info || "").gsub("\000", "").gsub("'", "`")
    end

    def os_username
      @os_username ||= `uname -n`.strip + "\\" + `id -un`.strip
    end

    # TODO
    def to_upload_data
      return "" if name.empty?

      out =  "- os_username: '#{os_username}'\n"
      out += "  app_name: '#{name}'\n"
      out += "  window_title: '#{title}'\n"
      out += "  extended_info: '#{extended_info}'\n"
      out += "  start_time: #{created_at}\n"
      out += "  end_time: #{finished_at}\n"

      return out
    end



    private
      def finish!
        @active = false
        @finished_at = Time.now
      end

      def current_application_name
        application_name(self.class.current_application_name)
      end

      def current_window_title
        window_title(self.class.current_window_title)
      end

      # To be overwritten
      def application_name(name)
        name
      end

      # To be overwritten
      def window_title(title)
        title
      end
  end
end



#- os_username: 'werbeboten-HP-Pavilion-g6-Notebook-PC\werbeboten'
#  app_name: 'werbeboten@werbeboten-HP-Pavilion-g6-Notebook-PC: ~/Dev/Rails3/BuecherdeParser'
#  window_title: 'werbeboten@werbeboten-HP-Pavilion-g6-Notebook-PC: ~/Dev/Rails3/BuecherdeParser'
#  extended_info: ''
#  start_time: 2012-02-10 11:56:52
#  end_time: 2012-02-10 11:56:57

