class Indexing::Sources::HeidiconKg < Indexing::Sources::Parents::Heidicon
  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      super
    end
  end

  def pool_name
    'IEK Europäische Kunstgeschichte'
  end
end
