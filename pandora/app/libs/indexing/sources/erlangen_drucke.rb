class Indexing::Sources::ErlangenDrucke < Indexing::SourceSuper
  def records
    document.xpath('//bvb')
  end

  def record_id
    record.xpath('.//pid/text()')
  end

  def path
    "#{record.at_xpath('.//premis/object/objectIdentifier/objectIdentifierValue/text()')}".gsub(/urn:nbn:de:bvb:29-/, '').sub(/-.\z/, '.jpg').sub(/-/, '_').capitalize
  end

  def s_unspecified
    ["Einblattdrucke"]
  end

  def _roleTermSet
    @_roleTermSet ||= record.xpath('.//mods/mods/name[@type="personal"]/role/roleTerm/text()')
  end

  # künstler
  def artist
    _roleTermSet.map{ |roleTerm|
      if roleTerm.to_s =="creator"
        roleTerm/'ancestor::name/namePart'
      end
    }
  end

  # titel
  def title
    record.xpath('.//mods/mods/titleInfo/title/text()')
  end

  # datierung
  def date
    record.xpath('.//mods/mods/originInfo/dateIssued[@keyDate="yes"]/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # institution
  def location
    "#{record.xpath('.//note/text()')}".gsub(/Einblattdrucke der /, '')
  end

  # erscheinungsort
  def publicationplace
    record.xpath('.//mods/mods/originInfo/place/placeTerm[@type="text"]/text()')
  end

  # formale Beschreibung
  def description
    record.xpath('.//mods/mods/physicalDescription/form/text()')
  end

  # verlag
  def publisher
    record.xpath('.//mods/mods/originInfo/publisher/text()')
  end

  # Bemerkungen
  def annotation
    if !(note ="#{record.xpath('.//note/text()')}").include?("Literatur:")
      note
    end
  end

  # literatur
  def literature
    if (literatur ="#{record.xpath('.//note/text()')}").include?("Literatur:")
      literatur
    end
  end

  # abbildungsnachweis
  def credits
    "Universitätsbibliothek Erlangen-Nürnberg"
  end

  # copyright
  def rights_reproduction
    "Alle Inhalte, insbesondere Fotografien und Grafiken, sind urheberrechtlich geschützt. Das Urheberrecht liegt, soweit nicht ausdrücklich anders gekennzeichnet, bei der Universitätsbibliothek Erlangen-Nürnberg.  Bitte holen Sie die Genehmigung zur Verwertung ein, insbesondere zur Weitergabe an Dritte, und übersenden Sie unaufgefordert ein kostenloses Belegexemplar."
  end

  def source_url
    record.xpath('.//viewer_url/text()')
  end
end
