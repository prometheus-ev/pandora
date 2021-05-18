class TestSource < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def record_object_id
    # @todo This ID calculation can be refactored by using #process_record_id in the Indexing::SourceParent class
    # for all sources with objects.
    # Currently: amsterdam_museum, amsterdam_rijksmuseum, dadaweb, daumier
    [name, Digest::SHA1.hexdigest(record.xpath('.//object-id/text()').to_a.join('|'))].join('-')
  end

  def path
    record.at_xpath('.//path/text()')
  end

  def artist
    record.xpath('.//artist/text()')
  end

  def artist_normalized
    super(artist)
  end

  def title
    record.xpath('.//title/text()')
  end

  def location
    record.xpath('.//location/text()')
  end

  def date
    record.xpath(".//date/text()")
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath(".//rights-reproduction/text()")
  end
end
