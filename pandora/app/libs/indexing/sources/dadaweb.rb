class Indexing::Sources::Dadaweb < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//zzzScan/text()')
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(record.xpath('.//zzzID_G/text()').to_a.join('|'))].join('-')
  end

  def s_location
    [record.xpath('.//zzzStandort/text()'), record.xpath('.//zzzInstitution/text()')]
  end

  def s_credits
    [record.xpath('.//zzzNachweis/text()'), record.xpath('.//zzzCopyright/text()')]
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      "B#{record.xpath('.//zzzScan/text()')}#{record.xpath('.//zzzBildpfad_Suffix2/text()')}"
    end
  end

  # künstler
  def artist
    record.xpath('.//zzzPerson/text()')
  end

  def artist_normalized
    an = "#{record.xpath('.//zzzPerson/text()')}".split(" \/ ").map { |a|
      a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//zzzTitel/text()')
  end

  # datierung
  def date
    record.xpath('.//zzzDatierung/text()')
  end

  def date_range
    date = record.xpath('.//zzzDatierung/text()').to_s

    super(date)
  end

  # standort
  def location
    (record.xpath('.//zzzStandort/text()') + record.xpath('.//zzzInstitution/text()')).map { |location|
      location.to_s.gsub(/Standort: /, '')
    }.delete_if { |location|
      location.blank?
    }.join(", ")
  end

  # material
  def material
    record.xpath('.//zzzMaterial/text()')
  end

  # groesse
  def size
    size = "#{record.at_xpath('.//zzzDim_H/text()')} x #{record.at_xpath('.//zzzDim_B/text()')} x #{record.at_xpath('.//zzzDim_T/text()')}"
    size = size.gsub(/ x  x /, "")
    size = size.gsub(/\A x /, "")
    size = size.gsub(/ x \z/, "")
    size = size + " " + "#{record.at_xpath('.//zzzDim_Format/text()')}" unless size.blank?
  end

  # gattung
  def genre
    record.xpath('.//zzzGattung/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//zzzNachweis/text()')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//zzzCopyright/text()')
  end

  def keyword_artigo
    super("dadaweb.xml")
  end
end
