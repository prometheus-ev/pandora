class Pandora::Indexing::Parser::DadawebRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//zzzScan/text()')
  end

  def record_object_id
    if !(object_id = record.xpath('.//zzzID_G/text()')).blank?
      [name, Digest::SHA1.hexdigest(object_id.to_a.join('|'))].join('-')
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "B#{record.xpath('.//zzzScan/text()')}#{record.xpath('.//zzzBildpfad_Suffix2/text()')}"
  end

  def artist
    record.xpath('.//zzzPerson/text()').to_s
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = "#{record.xpath('.//zzzPerson/text()')}".split(" \/ ").map { |a|
      a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('.//zzzTitel/text()')
  end

  def date
    record.xpath('.//zzzDatierung/text()')
  end

  def date_range
    return @date_range if @date_range

    date = record.xpath('.//zzzDatierung/text()').to_s

    @date_range = @date_parser.date_range(date)
  end

  def location
    (record.xpath('.//zzzStandort/text()') + record.xpath('.//zzzInstitution/text()')).map { |location|
      location.to_s.gsub(/Standort: /, '')
    }.delete_if { |location|
      location.blank?
    }.join(", ")
  end

  def material
    record.xpath('.//zzzMaterial/text()')
  end

  def size
    size = "#{record.at_xpath('.//zzzDim_H/text()')} x #{record.at_xpath('.//zzzDim_B/text()')} x #{record.at_xpath('.//zzzDim_T/text()')}"
    size = size.gsub(/ x  x /, "")
    size = size.gsub(/\A x /, "")
    size = size.gsub(/ x \z/, "")
    size = size + " " + "#{record.at_xpath('.//zzzDim_Format/text()')}" unless size.blank?
  end

  def genre
    record.xpath('.//zzzGattung/text()')
  end

  def credits
    record.xpath('.//zzzNachweis/text()')
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('.//zzzCopyright/text()')
  end

  def keyword_artigo
    @artigo_parser.keywords(record_id)
  end
end
