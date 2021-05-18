require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  test 'find by type' do
    assert_same_elements(
      ['painting', 'Italy 1988', 'Archaeology', 'Art history', 'Upload'],
      Keyword.pluck(:title)
    )
  end
end