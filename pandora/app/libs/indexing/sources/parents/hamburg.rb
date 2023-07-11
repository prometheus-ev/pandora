class Indexing::Sources::Parents::Hamburg < Indexing::SourceSuper
  def records
    @node_name = 'bilder'
    document.xpath('//bilder/bild')
  end

  def record_object_id
    # Record object ID preprocessing.
    if record.name == @node_name
      if !(record_object_id = record.xpath('./titel/text()')).empty?
        [name, Digest::SHA1.hexdigest(record_object_id.to_s)].join('-')
      end
    # Indexing.
    else
      if !title.empty?
        record_object_id = [name, Digest::SHA1.hexdigest(title.to_s)].join('-')

        if @record_object_id_count[record_object_id] && (@record_object_id_count[record_object_id] > 1)
          record_object_id
        end
      end
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end
end
