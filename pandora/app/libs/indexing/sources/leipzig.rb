class Indexing::Sources::Leipzig < Indexing::Sources::Parents::Dilps
  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      path_for('kuge_leipzig')
    end
  end
end
