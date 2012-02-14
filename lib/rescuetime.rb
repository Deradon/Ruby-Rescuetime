module Rescuetime
  require 'rescuetime/debug'
  require 'rescuetime/extension'

  require 'rescuetime/application'
  require 'rescuetime/config'
  require 'rescuetime/loop'
  require 'rescuetime/uploader'

  # Load Extensions
  Dir["#{File.dirname(__FILE__)}/rescuetime/extensions/**/*.rb"].each { |f| require f }

  # Load Extensions defined in users home directory
  Dir["#{Dir.home}/.ruby-rescuetime/extensions/**/*.rb"].each { |f| require f }
end

