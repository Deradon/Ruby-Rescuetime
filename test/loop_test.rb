require 'test_helper'

class Rescuetime::LoopTest < ActiveSupport::TestCase
  test "should not get new object through .new" do
    pending
    assert Rescuetime::Loop.new
  end

  test "should get Singleton through .create" do
    obj1 = Rescuetime::Loop.create
    obj2 = Rescuetime::Loop.create

    assert obj1 == obj2
  end
end

