require 'test_helper'
require "test_sources/test_source"

class Pandora::ImageVectorsTest < ActiveSupport::TestCase
  test "doesn't fail when image files are missing" do
    TestSource.index

    assert_nothing_raised do
      Pandora::ImageVectors.for_sources(['test_source'], ['dominant_colors'])
    end

    system "rm -rf #{ENV['PM_ROOT']}/pandora/tmp/test/vectors/test_source.json"
  end

  test 'simple run with results' do
    TestSource.index
    pid = Pandora::SuperImage.pid_for('test_source', 1)

    iv = Pandora::ImageVectors.new
    dc = Pandora::ImageVectors::DominantColors.new
    data = iv.generate([pid], [dc])

    assert_equal ['test_source'], data.keys

    record = data['test_source'][pid]
    assert_in_delta Time.now, record['last_run'], 10.seconds
    assert_equal 75292, record['size']
    color = record['features']['dominant_colors'].first
    assert color['count'].is_a?(Numeric)
    assert color['hsv'].is_a?(Array)

    file = "#{ENV['PM_VECTORS_DIR']}/test_source.json"
    assert_not File.exist?(file)

    iv.persist!
    assert File.exist?(file)
    data = JSON.parse(File.read(file))
    record = data[pid]
    assert record['features']['dominant_colors'].first['count'].is_a?(Numeric)
  end

  test 'freshness' do
    TestSource.index

    with_real_images do
      pid = Pandora::SuperImage.pid_for('test_source', 1)
      si = Pandora::SuperImage.new(pid)
      file = si.original_filename

      assert Pandora::ImageVectors.new.fresh?(file, {
        'last_run' => 2.days.ago,
        'size' => 75292,
        'mtime' => File.stat(file).mtime.utc
      })

      assert_not Pandora::ImageVectors.new.fresh?(file, {
        'last_run' => 2.years.ago,
        'size' => 75292,
        'mtime' => File.stat(file).mtime.utc
      })

      assert_not Pandora::ImageVectors.new.fresh?(file, {
        'last_run' => 2.days.ago,
        'size' => 12345,
        'mtime' => File.stat(file).mtime.utc
      })

      assert_not Pandora::ImageVectors.new.fresh?(file, {
        'last_run' => 2.days.ago,
        'size' => 48665,
        'mtime' => File.stat(file).mtime.utc - 2.months
      })
    end
  end

  test 'fetches dominant colors' do
    dc = Pandora::ImageVectors::DominantColors.new
    file = "#{Rails.root}/test/fixtures/files/skull.jpg"
    vectors = dc.dominant_colors(file)
    assert_equal 5, vectors.size
  end
end
