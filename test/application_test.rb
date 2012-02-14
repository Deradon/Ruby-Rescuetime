require 'test_helper'

p "..."

class Rescuetime::ApplicationTest < ActiveSupport::TestCase
  p ".."
  test ".current_application_name" do
    p "."
    assert Rescuetime::Application.current_application_name.is_a?(String)
  end

  test ".current_window_title" do
    assert Rescuetime::Application.current_window_title.is_a?(String)
  end
end

