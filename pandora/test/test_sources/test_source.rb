class TestSource < Indexing::SourceSuper
  def records
    @node_name = 'row'
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def record_object_id
    unless (object_id = record.xpath('.//object-id/text()')).blank?
      [name, Digest::SHA1.hexdigest(object_id.to_a.join('|'))].join('-')
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
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

  def date_range
    super(date.to_s)
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

  def source_url
    "https://nothing.nowhere.com/images/#{record_id}"
  end
end
