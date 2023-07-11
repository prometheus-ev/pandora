require 'test_helper'

class ElasticTest < ActiveSupport::TestCase
  test "doesn't trigger elastic max nested query exception" do
    skip "need to find solution, see #1529"

    TestSource.index
    jdoe = Account.find_by!(login: 'jdoe')

    # the limit is set to 1024 and we have no synonyms in the test env
    terms = 1025.times.map{|i| "term#{i}"}.join(' ')
    query = Pandora::Query.new(jdoe, {search_value: {'0' => terms}})
    results = query.run

    # no exception -> good
  end
end
