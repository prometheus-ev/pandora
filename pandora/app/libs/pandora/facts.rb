module Pandora
  module Facts
    def self.data
      Rails.cache.fetch 'facts', expires_in: 24.hours do
        elastic_counts = Pandora::Elastic.new.counts

        {
          :images => elastic_counts['total']['records'].to_s,
          :sources => elastic_counts.count - 1,
          :licenses => License.count_institutional,
          :accounts => Account.count_active_users.to_s
        }
      end
    end

    def self.facts
      return [
        '%s Images' / data[:images],
        '%d Databases' / data[:sources],
        '%d Licensed institutions' / data[:licenses],
        '%s Personal accounts' / data[:accounts]
      ]
    end
  end
end
