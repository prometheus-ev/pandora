class Pandora::SourceCollection < Pandora::Collection
  def to_json
    @items.map { |source|
      { :name => source.name,
        :title => source.title,
        :title_full => source.fulltitle,
        :kind => source.kind,
        :city => source.city,
        :location => source.institution.location,
        :url => source.url,
        :email => source.email,
        :keywords => source.keywords.map{ |keyword| keyword.title }.join(", "),
        :open_access => source.open_access? ? "Open access" : "Non-Open access",
        :record_count => source.record_count,
        :source_id => source.id,
        :institution_id => source.institution_id
      } unless source.kind == "User database"
    }.compact
  end
end
