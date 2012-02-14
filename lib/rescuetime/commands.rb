require 'rescuetime'
require 'optparse'

# This hash will hold all of the options
# parsed from the command-line by OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top of the help screen.
  opts.banner = "Usage: ruby-rescuetime [options]"

  # Define the options, and what they do
  opts.on( '-d', '--debug', 'View debug messages' ) do
    options[:debug] = true
  end

  opts.on( '-u', '--email EMAIL', 'Your email login used.' ) do |email|
    options[:email] = email
  end

  opts.on( '-p', '--password PASSWORD', 'Your password used.' ) do |password|
    options[:password] = password
  end

  options[:config] = File.join(Dir.home, ".ruby-rescuetime", "config.yml")
  opts.on( '-c', '--config FILE', 'Path to your config-file. (Default: ~/.ruby-rescuetime/config.yml)' ) do |config|
    options[:config] = config
  end

  options[:path] = File.join(Dir.home, ".ruby-rescuetime")
  opts.on('--path PATH', 'Path to your config directory. (Default: ~/.ruby-rescuetime/)' ) do |path|
    options[:path] = path
  end

  # This displays the help screen, all programs are assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

Rescuetime::Loop.new(options)

