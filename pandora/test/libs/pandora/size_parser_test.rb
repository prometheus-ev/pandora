require 'test_helper'

class Pandora::SizeParserTest < ActiveSupport::TestCase
  def assert_parses(parser, input)
    result = parser.parse(input)

    assert_not_nil result, "#{parser} could not parse '#{input}'"
  end

  def assert_parses_as(parser, input, expected)
    result = parser.parse(input)

    msg = "expected to parse '#{input}' as #{expected.inspect} but got #{result}"

    if expected.nil?
      assert_nil result, msg
    else
      assert_equal expected, result, msg
    end
  end

  # tests the sampe file, see
  # https://redmine.prometheus-srv.uni-koeln.de/issues/1389#note-11
  # test 'parses sample file' do
  #   parser = Pandora::SizeParser.new

  #   pid = nil
  #   input = []

  #   str = File.read("#{ENV['HOME']}/Desktop/size_field_samples")
  #   str.split("\n").each do |line|
  #     if (line.match(/^;/)) # ignore comments
  #       next
  #     end

  #     unless line.match(/^[a-z_]+-[a-z0-9]{40}$/)
  #       input << line
  #       next
  #     end

  #     unless input.empty?
  #       assert_parses parser, input.join("\n")
  #     end

  #     pid = line
  #     input = []
  #   end
  # end

  test 'parses specific values correctly' do
    parser = Pandora::SizeParser.new

    assert_parses_as(
      parser,
      "hoogte a: 85.4 cm\nbreedte a: 61.0 cm\nhoogte b: 65.0 cm",
      {'width' => 61.0, 'height' => 85.4}
    )

    assert_parses_as(
      parser,
      "46 X 54,5 cm",
      {'width' => 54.5, 'height' => 46.0}
    )

    assert_nil(
      parser.parse("320 cm"),
      nil
    )

    assert_parses_as(
      parser,
      "115 cm (w) x 210 cm (h)",
      {'width' => 210.0, 'height' => 115.0}
    )

    assert_parses_as(
      parser,
      "each: 10 3/8 × 7 1/16 in. (26.3 × 18 cm)",
      {'width' => 17.93875, 'height' => 26.3525}
    )

    assert_parses_as(
      parser,
      "48.70 mètres par 12.80",
      {'width' => 1280.0, 'height' => 4870.0}
    )
  end
end
