# A module representing the index mappings.
module Indexing::IndexMappings
  # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html
  def self.read
    # Remove some fields from the search field array, since they are treated specially below.
    search_fields = Rails.configuration.x.athene_search_fields['search'] - ['all', 'artist', 'artist_normalized', 'title', 'date', 'rating_average', 'record_id', 'record_object_id', 'description']

    properties = {
      artist: {
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/text.html
        type: "text",
        analyzer: "indexing_artist_analyzer",
        search_analyzer: "search_analyzer",
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/multi-fields.html
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-fields.html
        fields: {
          # raw is used for sorting.
          raw: {
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html
            type: "keyword",
            index: false
          }
        }
      },
      artist_normalized: {
        type: "text",
        analyzer: "indexing_pknd_analyzer",
        fields: {
          raw: {
            type: "keyword",
            index: false
          }
        }
      },
      title: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        fields: {
          raw: {
            type: "keyword",
            index: false
          }
        }
      },
      date: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
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
      rating_average: {
        type: "text",
        fields: {
          raw: {
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/number.html
            # TODO also add keyword field? See
            # https://www.elastic.co/guide/en/elasticsearch/reference/5.0/breaking_50_mapping_changes.html
            type: "float"
          }
        }
      },
      record_id: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword"
          }
        }
      },
      record_object_id: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes",
        fields: {
          raw: {
            type: "keyword"
          }
        }
      },
      description: {
        type: "text",
        analyzer: "indexing_analyzer",
        search_analyzer: "search_analyzer",
        term_vector: "yes"
      }
    }

    for search_field in search_fields do
      properties.merge!({
        search_field.to_sym => {
          type: "text",
          analyzer: "indexing_analyzer",
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-analyzer.html
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

  def self.search_fields
    read[:properties].keys - [:date_range, :date_range_from, :date_range_to, :artist_normalized]
  end
end
