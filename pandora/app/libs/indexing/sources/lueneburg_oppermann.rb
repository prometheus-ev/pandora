class Indexing::Sources::LueneburgOppermann < Indexing::SourceSuper
  TITLE_ADDITION = {
    13001..13215 => 'Öl auf Leinwand',
    23001..23574 => 'MKÜVO',
    33001..33026 => 'MKÜVO-Fensterecke'
  }.inject({}) { |hash, (range, addition)|
    range.each { |key| hash["a#{key}"] = addition }
    hash
  }

  SKIP_ANNOTATION = [
    'Vorderseite', 'Rückseite', 'Standardansicht',
    'weitere Ansicht', 'weitere Ansichten'
  ]

  DEPOT_IDS  = %w[g1 g50 g69 g70 g71 g72 g82]
  ALTONA_IDS = %w[g73 g74 g75 g76 g78]

  XPRED_LANG = "[@lang='%s']"

  def records
    document.xpath("//petal/object/view[starts-with(@id, 'a')]")
  end

  def record_id
    record.xpath('@id')
  end

  def _value(key, lang = nil)
    record.xpath(".//../metadata#{XPRED_LANG % lang if lang}/record/value[@key='#{key}']/text()")
  end

  def _id
    record.at_xpath('@id').to_s
  end

  def credits
    'Nachlass Anna Oppermann'
  end

  def path
    "#{record.xpath('@id')}.jpg"
  end

  def artist
    ['Anna Oppermann']
  end

  # titel
  def title
    if addition = TITLE_ADDITION[_id]
      "Zusatzmaterial zu: #{addition}"
    else
      title = _value('title').to_s
      title.blank? ? 'ohne Titel' : title
    end
  end

  # datierung
  def date
    _value('date', 'de')
  end

  # standort
  def location
    refs = (record.xpath('.//annotation/line/link/@ref')).map(&:to_s)

    if (refs & DEPOT_IDS ).any?
      'Depot Anna Oppermann'
    else
      if (refs & ALTONA_IDS).any?
        'Hamburg, Altonaer Rathaus'
      else
        'Hamburg, Kunsthalle'
      end
    end
  end

  # material
  def material
    _value('material')
  end

  def size
    _value('masse', 'de')
  end

  def inscription
    record.xpath(".//inscription[contains(@id, '#{_id}')]/content#{XPRED_LANG % 'de'}/line/text()")
  end

  def annotation
    record.xpath(".//annotation[@lang='de']/line").to_a.map { |node|
      node.content = '' if SKIP_ANNOTATION.include?(node.text)
      node.content
    }
  end

  def comment
    @_d_comment ||= _value('comment')
  end

  def inventory_no
    @_d_inventory_no ||= _value('invnr', 'de')
  end

  # copyright
  def rights_reproduction
    fotographer = "#{record.xpath(".//source#{XPRED_LANG % 'de'}/text()")}".gsub(/Foto: /, '')
    fotographer.blank? ? 'Carmen Wedemeyer' : fotographer
  end

  def rights_work
    'Nachlass Anna Oppermann'
  end
end
