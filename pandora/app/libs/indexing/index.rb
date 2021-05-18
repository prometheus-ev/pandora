require 'date'

# This class performs all actions on the Index.
#
# == Usage
# Get an array of all existing indices:
#   Indexing::Index.indices
# Get an array of all existing aliases:
#   Indexing::Index.aliases
# Delete an index:
#   Indexing::Index.delete("robertin")
# Count the records of an index:
#   Indexing::Index.count("robertin")
# Count all records:
#   Indexing::Index.count
class Indexing::Index
  # Use concerns, see concern directory.
  # https://signalvnoise.com/posts/3372-put-chubby-models-on-a-diet-with-concerns
  include Indexing::Concerns::IndexUtils

  # Client getter.
  attr_reader :client

  # Initialize the index by connecting to the client.
  def initialize(log = Rails.env.development?)
    # http://www.rubydoc.info/gems/elasticsearch-transport/#Configuration
    uri = URI.parse(ENV['PM_ELASTIC_URI'])
    @client = Elasticsearch::Client.new(
      host: uri.host,
      port: uri.port,
      request_timeout: 5 * 60,
      log: log
    )
  end

  # Get an array of index alias names.
  #
  # @return [Array] An array of index alias names.
  def aliases
    # Map index aliases names, reject empty ones.
    @index_aliases ||= client.indices.get_alias.values.reject { |index_alias|
      index_alias["aliases"] == {}
    }.map { |index_alias|
      index_alias["aliases"].keys[0]
    }
  end

  # Get all index names as an array of strings.
  #
  # @return [Array] An array of index name strings.
  def indices
    client.indices.get_settings.keys.sort
  end


  # Create an index with settings and mappings.
  #
  # @param index_name [String] The name of the index to create.
  def create(index_name)
    unless client.indices.exists? index: index_name
      client.indices.create index: index_name, body: {
        settings: Indexing::IndexSettings.read,
        mappings: Indexing::IndexMappings.read
      }
    end
  end

  # Delete an index and clear the cache.
  #
  # @param index_name [String] The name of the index to create.
  def delete(index_name)
    if client.indices.exists? index: index_name
      client.indices.delete index: index_name
      client.indices.clear_cache
    end
  end

  # Count the numer of records of a specified index or of all indices.
  #
  # @param index_name [String] The index name to count.
  #
  # @return [Fixnum] The number of records of the queried index or 0.
  def count(index_name = "_all")
    if index_name == "_all"
      client.count(index: Source.active_names.join(","), ignore_unavailable: true)['count']
    elsif client.indices.exists? index: index_name
      client.count({ index: index_name })['count']
    else
      0
    end
  end

  # Process indices params.
  #
  # @param params_indices [Hash] A hash of indices to process.
  #
  # @return [Hash] A processed hash with all indices params that existed and have a source
  #                enhanced with all needed source data.
  def process_indices(params_indices)
    if params_indices.present?
      # Reject aliases that are not available as sources.
      aliases = self.aliases.sort.reject { |alias_name|
        !source_names.include?(alias_name) || client.count(index: alias_name, ignore_unavailable: true)["count"] == 0
      # Go through all existing index aliases and set them as checked if they exist as param, set them unchecked if they do not exist as param.
      }.map { |alias_name|
        if params_indices[alias_name] == "true"
          [alias_name, { checked: true }]
        else
          [alias_name, { checked: false }]
        end
      }.to_h
      # Reject indices that are not available as sources.
      indices = self.indices.sort.reject { |index_name|
        !source_names.include?(alias_name_from_index_name(index_name)) || client.count(index: alias_name_from_index_name(index_name), ignore_unavailable: true)["count"] == 0
      # Go through all existing indices and set them as checked if they exist as param, set them unchecked if they do not exist as param.
      }.map { |index_name|
        source_name = alias_name_from_index_name(index_name)
        if params_indices[source_name] == "true"
          [source_name, { checked: true }]
        else
          [source_name, { checked: false }]
        end
      }.to_h

      indices.merge!(aliases)
    else
      # Reject aliases that are not available as sources.
      aliases = self.aliases.sort.reject { |alias_name|
        !source_names.include?(alias_name) || client.count(index: alias_name, ignore_unavailable: true)["count"] == 0
      # Set all index aliases checked by default.
      }.map { |alias_name|
        [alias_name, { checked: true }]
      }.to_h
      # Reject indices that are not available as sources.
      indices = self.indices.sort.reject { |index_name|
        !source_names.include?(alias_name_from_index_name(index_name)) || client.count(index: alias_name_from_index_name(index_name), ignore_unavailable: true)["count"] == 0
      # Set all indices checked by default.
      }.map { |index_name|
        [alias_name_from_index_name(index_name), { checked: true }]
      }.to_h

      indices.merge!(aliases)
    end

    # Extend indices hash to include source model data
    sources.each { |source|
      if indices[source.name]
        indices[source.name].merge!(source: {
          name: source.name,
          title: source.title,
          fulltitle: source.fulltitle,
          kind: source.kind,
          city: source.city,
          location: source.institution.location,
          url: source.url,
          email: source.email,
          keywords: source.keywords.map{ |keyword| keyword.title }.join(", "),
          open_access: source.open_access? ? "Open access" : "Non-Open access",
          source_id: source.id,
          institution_id: source.institution.id
        })
      end
    }

    indices
  end

  def sources
    @sources ||= Source.all
  end

  def source_names
    @source_names ||= sources.map { |source|
      source.name
    }
  end

  # @return [Hash] Number of total records and number of records per index.
  def number_of
    records = {}
    records[:total] = client ? count : 0

    # Go through index aliases reject those which do not have a source.
    aliases.sort.reject { |alias_name|
      !source_names.include?(alias_name)
    }.each { |alias_name|
      records[alias_name] = client ? count(alias_name) : 0
    }

    { records: records }
  end

  # Get the current index name from an index alias name.
  #
  # @param alias_name [String] The name of an index alias.
  def index_name_from_alias_name(alias_name)
    if client.indices.exists?(index: alias_name)
      client.indices.get_alias(name: alias_name).keys[0].dup
    end
  end

  # Get the index alias name from a current index name.
  #
  # @param index_name [String] The name of an index alias.
  def alias_name_from_index_name(index_name)
    index_name.gsub(/_\d+/, "")
  end
end
