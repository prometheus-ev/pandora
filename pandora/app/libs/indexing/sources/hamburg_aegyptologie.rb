class Indexing::Sources::HamburgAegyptologie < Indexing::SourceSuper
  def records
    document.xpath('//bilder/bild')
  end

  def record_id
    @mapping ||= begin
      ids_file = File.open(File.join(Rails.configuration.x.dumps_path, "hamburg_dilps_ids"))
      ids_document = Nokogiri::XML(File.open(ids_file)) do |config|
        config.noblanks
      end

      result = {}
      ids_document.xpath('//objekt').each do |e|
        id = e.xpath('id').text
        dilps_id = e.xpath('dilps_id').text
        if id.present? && dilps_id.present?
          result[id] = dilps_id
        end
      end
      result
    end

    text = "#{record.xpath('ancestor::bilder/easydb4_reference/text()')}"

    if text.blank?
      record.xpath('.//files/file/eas-id/text()')
    else
      current_id = text.sub(/Bilder:/, "")
      @mapping[current_id] || current_id
    end
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(record.xpath('ancestor::bilder/_id/text()').to_a.join('|'))].join('-')
  end

  def path
    if (full = "#{record.at_xpath('.//files/file/versions/version[@name="full"]/url/text()')}").blank?
      url = "#{record.at_xpath('.//files/file/versions/version[@name="original"]/url/text()')}"
    else
      url = full
    end
      url.sub(/http:\/\/kultdokuhh.fbkultur.uni-hamburg.de\//, '').sub(/http:\/\/localhost\//, '').sub(/https:\/\/kultdokuhh4.fbkultur.uni-hamburg.de\//,'').sub(/https:\/\/kultdokuhh-4.fbkultur.uni-hamburg.de\//,'')
  end

  # künstler
  def artist
    record.xpath('ancestor::bilder/_nested__bilder__kuenstler/bilder__kuenstler/lk_kuenstler_id/kuenstler/name/text()')
  end

  def artist_normalized
    an = artist.map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('ancestor::bilder/titel/text()')
  end

  # datierung
  def date
    record.xpath('ancestor::bilder/datum/text()')
  end

  # standort
  def location
    "#{record.xpath('ancestor::bilder/ort_id/ort/name/text()')}, #{record.xpath('ancestor::bilder/institution/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # herstellort
  def manufacture_place
    record.xpath('ancestor::bilder/herstellort_id/ort/name/text()')
  end

  # technik
  def material
    record.xpath('ancestor::bilder/technik_material/text()')
  end

  # Gattung
  def genre
    record.xpath('ancestor::bilder/gattung/text()')
  end

  # Masse
  def size
    record.xpath('ancestor::bilder/masse/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('ancestor::bilder/abbildungsnachweis/text()')
  end

  # copyright
  def rights_reproduction
    record.xpath('ancestor::bilder/copyrightnachweis/text()')
  end

  # Schlagwörter
  def keyword
    record.xpath('ancestor::bilder/darstellung_thema/text()')
  end
end
