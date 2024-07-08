require 'test_helper'

class AnalyzerTest < ActiveSupport::TestCase
  setup do
    new_index_name = Pandora::Elastic.new.create_index('test')
    Pandora::Elastic.new.add_alias_to(index_name: new_index_name)
  end


  # skip: For local analyzer testing only.
  test 'analyzer with term r. bauer @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_search_analyzer', 'R. Bauer'

    # puts JSON.pretty_generate(analysis)
  end

  # skip: For local analyzer testing only.
  test 'analyzer with term rafael @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_search_analyzer', 'rafael'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_indexing_analyzer', 'Raffaello &lt;Sanzio&gt;'

    # puts JSON.pretty_generate(analysis)
  end

  # skip: For local analyzer testing only.
  test 'analyzer with term klapsch @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'indexing_analyzer', 'Herr Klapsch'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'search_analyzer', '*Klapsch*'

    # puts JSON.pretty_generate(analysis)
  end

  # skip: For local analyzer testing only.
  test 'analyzers with term müller @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'indexing_analyzer', 'müller'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'search_analyzer', 'müller'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_indexing_analyzer', 'müller'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_search_analyzer', 'müller'

    # puts JSON.pretty_generate(analysis)
  end

  # skip: For local analyzer testing only.
  test 'analyzer with term dorothea lange @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_indexing_analyzer', 'dorothea lange'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'artist_normalized_search_analyzer', 'dorothea lange'

    # puts JSON.pretty_generate(analysis)
  end

  # skip: For local analyzer testing only.
  test 'analyzers with term sunflower asterisk @skip' do
    analysis = Pandora::Elastic.new.analyze 'test', 'indexing_analyzer', 'sonnenblume*'

    # puts JSON.pretty_generate(analysis)

    analysis = Pandora::Elastic.new.analyze 'test', 'search_analyzer', 'sonnenblume*'

    # puts JSON.pretty_generate(analysis)
  end
end
