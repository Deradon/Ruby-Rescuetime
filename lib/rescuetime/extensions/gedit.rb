class Rescuetime::Gedit < Rescuetime::Application
  APPLICATION = "Gedit"
  include Rescuetime::Extension

  def window_title(title)
    (title.start_with?("*") ? title[1..-1] : title).gsub(/- gedit$/, '').strip
  end

  def extended_info
    title.match(/\(([^\(]*)\)$/).to_a[1] || ""
  end
end

