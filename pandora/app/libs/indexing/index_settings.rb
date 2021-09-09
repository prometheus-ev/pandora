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
          # Add synonyms with the synonym token filter. For general information and for information
          # on how to update synonyms, see:
          # https://www.elastic.co/guide/en/elasticsearch/guide/current/synonyms.html
          # For infos about the synonym token filter, see:
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-fields.html#_multi_fields_with_multiple_analyzers
          # https://www.elastic.co/guide/en/elasticsearch/guide/current/synonyms-expand-or-contract.html#synonyms-genres
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-tokenfilter.html
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-graph-tokenfilter.html
          # PKND synonyms:
          synonym_graph_pknd: {
            type: "synonym_graph",
            synonyms_path: File.join(Rails.configuration.x.synonyms_path, "pknd.txt")
          },
          # Masternames synonyms:
          synonym_graph_masternames: {
            type: "synonym_graph",
            synonyms_path: File.join(Rails.configuration.x.synonyms_path, "masternames.txt")
          },
          # German, Engish dictionary synonyms
          synonym_graph_de_en: {
            type: "synonym_graph",
            synonyms_path: File.join(Rails.configuration.x.synonyms_path, "de_en.txt")
          },
          # Add further synonyms that might be needed here.
          synonym_graph_others: {
            type: "synonym_graph",
            synonyms_path: File.join(Rails.configuration.x.synonyms_path, "others.txt")
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
          },
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
          }
        },
        # Some info about analyzers:
        #
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-htmlstrip-charfilter.html
        # char_filter: ["html"],
        #
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenizers.html
        # A tokenizer of type letter that divides text at non-letters. The letter tokenizer provides better
        # results than the standard tokenizer which was in use before. E.g. the standard tokenizer
        # did not tokenize "d'Augustusburg", thus queries for "augustusburg" did not deliver all expected
        # results.
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-letter-tokenizer.html
        # However, the letter tokenizer removes numbers in strings and thus is not suitable for string fields
        # with included numbers. In order to handle the problem with the apostrophe in "d'Augustusburg" a
        # word_delimiter token filter will be added.
        # With Elasticsearch version 7.x the following BadRequest error is thrown:
        # "type":"illegal_argument_exception","reason":"Token filter [word_delimiter] cannot be used to parse synonyms"
        # Thus, we remove the word_delimiter filter and add the elision filter which will care about "d'Augustusburg" now.
        # The standard tokenizer provides grammar based tokenization
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-standard-tokenizer.html
        # tokenizer: "standard",
        #
        # filter:
        #
        # Splits words into subwords and performs optional transformations on subword groups.
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-word-delimiter-tokenfilter.html
        # Deprecated.
        # "word_delimiter",
        #
        # Removes specified elisions from the beginning of tokens. For example, you can use this filter
        # to change l'avion to avion.
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-elision-tokenfilter.html
        # "elision",
        #
        # A token filter of type lowercase that normalizes token text to lower case.
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-lowercase-tokenfilter.html
        # "lowercase",
        #
        # Strips diacritics and tries to convert many Unicode characters into a simpler ASCII representation.
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/asciifolding-token-filter.html
        # "asciifolding",
        #
        # Expand with de/en and inline synonyms.
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-tokenfilter.html
        # "synonym_de_en",
        # "synonym_pknd"
        #
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
              "synonym_graph_others",
              "synonym_graph_de_en"
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
              "synonym_graph_pknd",
              "synonym_graph_masternames"
            ]
          }
        }
      }
    })

    { index: index }
  end
end
