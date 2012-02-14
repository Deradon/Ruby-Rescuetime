class Rescuetime::Chromium < Rescuetime::Application
  APPLICATION = "Chromium-browser"
  include Rescuetime::Extension
  include Rescuetime::Debug

  def window_title(given_title)
    title = given_title.gsub(/- Chromium$/, '').strip
    t = title.downcase
    if t["google mail"]
      return "http://www.mail.google.com"
    elsif t["twitter"]
      return "http://www.twitter.com"
    elsif t["facebook"]
      return "http://www.facebook.com"
    else
      return t
    end
  end

  alias :old_name :name
  def name
    ["google mail", "twitter", "facebook"].each do |e|
      return "#{e} - chromium" if title[e]
    end
    "#{title} - chromium"
  end

#  def extended_info
#    title
#  end
end

