require 'test_helper'

class IpRangeTest < ActiveSupport::TestCase
  test 'parser' do
    parser = Pandora::IpRange

    assert_equal :invalid, parser.parse('16')
    assert_equal :invalid, parser.parse('399.0.0.0')
    assert_equal :invalid, parser.parse('127.0.0.-1')
    assert_equal :invalid, parser.parse('zt::')

    parsed = parser.parse('10.0.50.70-10.0.50.80')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.50.70'),
      IPAddr.new('10.0.50.80')
    )
    assert_equal expected, parsed

    parsed = parser.parse('10.0.50.70-80')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.50.70'),
      IPAddr.new('10.0.50.80')
    )
    assert_equal expected, parsed

    parsed = parser.parse('10.0.50-60.1-255')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.50.1'),
      IPAddr.new('10.0.60.255')
    )
    assert_equal expected, parsed

    parsed = parser.parse('10.0.50')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.50.0'),
      IPAddr.new('10.0.50.255')
    )
    assert_equal expected, parsed

    parsed = parser.parse('10.0.50-60')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.50.0'),
      IPAddr.new('10.0.60.255')
    )
    assert_equal expected, parsed

    parsed = parser.parse('-10.0.12.199')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.12.199'),
      IPAddr.new('10.0.12.199'),
      exclude: true
    )
    assert_equal expected, parsed

    parsed = parser.parse('192.129.10-192.129.14')
    expected = Pandora::IpRange.new(
      IPAddr.new('192.129.10.0'),
      IPAddr.new('192.129.14.255')
    )
    assert_equal expected, parsed

    parsed = parser.parse('10.0.12.199 ')
    expected = Pandora::IpRange.new(
      IPAddr.new('10.0.12.199'),
      IPAddr.new('10.0.12.199'),
    )
    assert_equal expected, parsed
  end
end
