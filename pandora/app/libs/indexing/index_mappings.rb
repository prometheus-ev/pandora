# A module representing the index mappings.
#
# Elasticsearch Reference
# https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html
module Indexing::IndexMappings
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html
  def self.read
    properties = {
      record_id: {
        # TODO Type text should not be needed here, we might be able to remove it.
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        fields: {
          raw: {
            type: "keyword"
            # Index the keyword field since we need to search for exact matches. true is the default for keyword fields.
            # index: true
          }
        }
      },
      record_object_id: {
        # TODO Type text should not be needed here, we might be able to remove it.
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        fields: {
          raw: {
            type: "keyword"
            # Index the keyword field since we need to search for exact matches. true is the default for keyword fields.
            # index: true
          }
        }
      },
      record_object_id_count: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        fields: {
          raw: {
            type: "keyword"
          },
          short: {
            type: 'short'
          }
        }
      },
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/nested.html
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/sort-search-results.html#nested-sorting
      artist_nested: {
        type: 'nested',
        include_in_parent: true
      },
      # The artist field as type text for searching and type keyword for sorting.
      artist: {
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/text.html
        type: "text",
        analyzer: "indexing_analyzer",
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-analyzer.html
        search_analyzer: "search_analyzer",
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/term-vector.html
        term_vector: "yes",
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/multi-fields.html
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-fields.html
        fields: {
          # raw is used for sorting.
          raw: {
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html
            type: 'keyword',
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      # The artist_normalized field is filled with a normalized version of artist name from field artist
      # and also enhanced with its synonyms from the PKND file:
      #
      # config/synonyms/pknd.txt
      #
      # For implementation, see:
      #
      # app/libs/indexing/source_super.rb
      #
      # and all sources implementing artist_normalized at:
      #
      # app/libs/indexing/sources
      artist_normalized: {
        type: "text",
        analyzer: "artist_normalized_indexing_analyzer",
        search_analyzer: "artist_normalized_search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            index: false
          }
        }
      },
      title_nested: {
        type: 'nested',
        include_in_parent: true
      },
      title: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      location_nested: {
        type: 'nested',
        include_in_parent: true
      },
      location: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      date: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            index: false
          }
        }
      },
      date_range: {
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/range.html
        type: "date_range",
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-date-format.html
        # https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html
        format: Rails.configuration.x.indexing_custom_date_formats.join('||'),
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/ignore-malformed.html#json-object-limits
        # ignore_malformed: true cannot be used for date ranges.
      },
      # For sorting and min/max aggregations.
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-min-aggregation.html
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-metrics-max-aggregation.html
      # https://github.com/elastic/elasticsearch/issues/34644
      date_range_from: {
        type: "date",
        format: Rails.configuration.x.indexing_custom_date_formats.join('||')
      },
      date_range_to: {
        type: "date",
        format: Rails.configuration.x.indexing_custom_date_formats.join('||')
      },
      credits_nested: {
        type: 'nested',
        include_in_parent: true
      },
      credits: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      rights_work: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      rights_reproduction_nested: {
        type: 'nested',
        include_in_parent: true
      },
      rights_reproduction: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword",
            normalizer: 'sort_normalizer',
            index: false
          }
        }
      },
      rating_count: {
        type: "text",
        term_vector: "yes",
        fields: {
          short: {
            type: 'short'
          },
          raw: {
            type: "keyword",
            index: false
          }
        }
      },
      rating_average: {
        type: "text",
        term_vector: "yes",
        fields: {
          raw: {
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/number.html
            # TODO also add keyword field? See
            # https://www.elastic.co/guide/en/elasticsearch/reference/5.0/breaking_50_mapping_changes.html
            type: "float"
            # Index the float field since we use it in search. true is the default for float fields.
            # index: true
          }
        }
      },
      description: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes"
      },
      license_nested: {
        type: 'nested',
        include_in_parent: true
      },
      person_nested: {
        type: 'nested',
        include_in_parent: true
      },
      # See #1638.
      authority_files: {
        type: 'nested',
        include_in_parent: true
      },
      # Field required for image search. See #1271 and #1289.
      image_vector: {
        type: "dense_vector",
        dims: 80
      },
      domainant_color1: {
        type: "dense_vector",
        dims: 3
      },
      is_main_record: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword"
          }
        }
      }
    }

    # Mapping fields that are handled the same.
    Indexing::IndexFields.index_mapping.each do |index_mapping_field|
      properties.merge!({
        index_mapping_field.to_sym => {
          type: "text",
          analyzer: "indexing_analyzer",
          search_analyzer: "search_analyzer",
          term_vector: "yes",
          fields: {
            raw: {
              type: "keyword",
              index: false
            }
          }
        }
      })
    end

    mappings = {
      # _all field is deprecated since 6.0 and thus is removed, see:
      # https://www.elastic.co/guide/en/elasticsearch/reference/6.0/mapping-all-field.html
      # and:
      # https://www.elastic.co/guide/en/elasticsearch/reference/6.0/breaking_60_mappings_changes.html#_the_literal__all_literal_meta_field_is_now_disabled_by_default
      properties: properties
    }
  end
end
