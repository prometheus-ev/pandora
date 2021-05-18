require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
  test 'handle the common cases' do
    date = Date.new(2019, 7, 31)
    assert_equal '2019/3', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 7, 2)
    assert_equal '2019/3', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 6, 30)
    assert_equal '2019/2', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 6, 1)
    assert_equal '2019/2', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 1, 30)
    assert_equal '2019/1', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 12, 30)
    assert_equal '2019/4', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 12, 31)
    assert_equal '2019/4', Pandora::Utils.quarter_for(date)

    date = Date.new(2019, 12, 1)
    assert_equal '2019/4', Pandora::Utils.quarter_for(date)
  end
end
