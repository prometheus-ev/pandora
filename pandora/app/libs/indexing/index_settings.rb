# A module representing the index settings.
module Indexing::IndexSettings
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#dynamic-index-settings
  MAX_RESULT_WINDOW = 3000000

  # Define the index settings.
  #
  # @param update [Boolean] Update or create.
  def self.read(update = false)
    index = {}

    unless update
      index.merge!( {
        number_of_shards: 1,
        number_of_replicas: 0
      } )
    end

    index.merge!({
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html
      # In the furture, use scoll in order to request large numbers of results:
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-scroll.html
      max_result_window: MAX_RESULT_WINDOW,
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html
      analysis: {
        filter: {
          # Combined synonyms de_en.txt and others.txt for the search_analyzer.
          synonym_graph_search_analyzer: {
            type: "synonym_graph",
            synonyms_path: File.join(ENV['PM_SYNONYMS_DIR'], "search_analyzer.txt")
          },
          # Combined synonyms pknd.txt and masternames.txt for the artist_normalized_search_analyzer.
          synonym_graph_artist_normalized_search_analyzer: {
            type: "synonym_graph",
            synonyms_path: File.join(ENV['PM_SYNONYMS_DIR'], "artist_normalized_search_analyzer.txt")
          },
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lang-analyzer.html#german-analyzer
          german_stemmer: {
            type: "stemmer",
            language: "light_german"
          },
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-word-delimiter-tokenfilter.html
          word_delimiter: {
            type: "word_delimiter",
            preserve_original: true
          }
        },
        char_filter: {
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-htmlstrip-charfilter.html
          html: {
            type: "html_strip"
          },
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-pattern-replace-charfilter.html
          replace_punctuation: {
            type: "pattern_replace",
            # http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html
            pattern: "(\\w*)\\p{Punct}(?=\\w*)",
            replacement: "$1"
          },
          prepend_z_before_non_alpha_only_chars_for_sorting: {
            type: 'pattern_replace',
            # http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html
            # Prepend five times z before all non-alpha and -umlaut characters to sort them at the end of the result list.
            pattern: '(^[^A-Za-zÀ-ÿ]*$)',
            replacement: 'zzzzz$1'
          },
          remove_non_alpha_chars_for_sorting: {
            type: 'pattern_replace',
            # http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html
            # Remove all preceeding non-alpha and -umlaut characters.
            pattern: '^[^A-Za-zÀ-ÿ]*',
            replacement: ''
          }
        },
        # When working with analyzers, testing them can be helpful:
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/analysis-intro.html#analyze-api
        analyzer: {
          indexing_analyzer: {
            type: "custom",
            char_filter: ["html"],
            tokenizer: "standard",
            filter: [
              "elision",
              "lowercase",
              "asciifolding"
            ]
          },
          search_analyzer: {
            type: "custom",
            char_filter: ["html"],
            tokenizer: "standard",
            filter: [
              "elision",
              "lowercase",
              "asciifolding",
              "synonym_graph_search_analyzer"
            ]
          },
          artist_normalized_indexing_analyzer: {
            type: "custom",
            char_filter: [ "html", "replace_punctuation" ],
            tokenizer: "keyword",
            filter: [
              "elision",
              "lowercase",
              "asciifolding"
            ]
          },
          artist_normalized_search_analyzer: {
            type: "custom",
            char_filter: [ "html", "replace_punctuation" ],
            tokenizer: "keyword",
            filter: [
              "elision",
              "lowercase",
              "asciifolding",
              "synonym_graph_artist_normalized_search_analyzer"
            ]
          }
        },
        normalizer: {
          sort_normalizer: {
            type: 'custom',
            char_filter: ['prepend_z_before_non_alpha_only_chars_for_sorting', 'remove_non_alpha_chars_for_sorting'],
            filter: [
              # Not sure if we need the elision filter here. Causes problems with e.g. the title of record:
              #
              # ingrid-c6137694906279ee15194b0d91d587c03f19dc3a
              # title: 12 | c'11 | cKs
              #
              #'elision',
              'lowercase',
              'asciifolding'
            ]
          }
        }
      }
    })

    { index: index }
  end
end
